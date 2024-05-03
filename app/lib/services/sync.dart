import 'dart:async';

import 'package:butterfly/api/file_system/file_system.dart';
import 'package:butterfly_api/butterfly_api.dart';
import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

import '../api/file_system/file_system_dav.dart';
import '../api/file_system/file_system_remote.dart';
import '../cubits/settings.dart';

class SyncService {
  final BuildContext context;
  final List<RemoteSync> _syncs = [];
  final SettingsCubit settingsCubit;
  final BehaviorSubject<SyncStatus> _statusSubject =
      BehaviorSubject<SyncStatus>();
  Stream<SyncStatus> get statusStream => _statusSubject.stream;
  SyncStatus? get status => _statusSubject.valueOrNull;

  SyncService(this.context, this.settingsCubit) {
    settingsCubit.stream.listen(_loadSettings);
    _loadSettings(settingsCubit.state);
  }

  RemoteSync? getSync(String remote) {
    if (kIsWeb) return null;
    var current = _syncs
        .firstWhereOrNull((sync) => sync.remoteStorage.identifier == remote);
    current ??= _createSync(remote);
    return current;
  }

  RemoteSync? _createSync(String remote) {
    if (kIsWeb) return null;
    final storage = settingsCubit.state.getRemote(remote);
    if (storage == null) {
      return null;
    }
    final current = RemoteSync(context, settingsCubit, storage);
    current.statusStream.listen((status) => _refreshStatus());
    _syncs.add(current);
    current.autoSync();
    return current;
  }

  Future<void> sync() async {
    if (kIsWeb) return;
    for (final sync in _syncs) {
      await sync.sync();
    }
  }

  bool _hasSync(String remote) {
    if (kIsWeb) return false;
    return _syncs.any((sync) => sync.remoteStorage.identifier == remote);
  }

  void _loadSettings(ButterflySettings settings) {
    if (kIsWeb) return;
    for (final remote in settings.connections) {
      if (!_hasSync(remote.identifier)) _createSync(remote.identifier);
    }
    _refreshStatus();
  }

  void _refreshStatus() {
    if (kIsWeb) return;
    var syncStatus = SyncStatus.synced;
    for (final sync in _syncs) {
      if (sync.status == SyncStatus.error) {
        syncStatus = SyncStatus.error;
        break;
      } else if (sync.status == SyncStatus.syncing) {
        syncStatus = SyncStatus.syncing;
      }
    }
    _statusSubject.add(syncStatus);
  }

  List<RemoteSync> get syncs => List.unmodifiable(_syncs);
}

enum SyncStatus {
  synced,
  syncing,
  error,
}

class RemoteSync {
  final BuildContext context;
  final ExternalStorage remoteStorage;
  final SettingsCubit settingsCubit;
  final BehaviorSubject<List<SyncFile>> _filesSubject =
      BehaviorSubject<List<SyncFile>>();
  final BehaviorSubject<SyncStatus> _statusSubject =
      BehaviorSubject<SyncStatus>();

  Stream<List<SyncFile>> get filesStream => _filesSubject.stream;
  List<SyncFile>? get files => _filesSubject.valueOrNull;
  Stream<SyncStatus> get statusStream => _statusSubject.stream;
  SyncStatus? get status => _statusSubject.valueOrNull;

  RemoteSync(this.context, this.settingsCubit, this.remoteStorage) {
    _filesSubject.onListen = _onListen;
  }

  Future<void> _refreshSyncStatus() async {
    if (status == SyncStatus.syncing) {
      return;
    }
    final fileSystem = DocumentFileSystem.fromPlatform(remote: remoteStorage)
        as DavRemoteDocumentFileSystem;
    final currentFiles = await fileSystem.getAllSyncFiles();
    _filesSubject.add(currentFiles);
  }

  Future<void> autoSync() async {
    final syncMode = settingsCubit.state.syncMode;
    if (syncMode == SyncMode.manual) {
      return;
    }
    if (syncMode == SyncMode.noMobile &&
        !(await Connectivity().checkConnectivity())
            .contains(ConnectivityResult.mobile)) {
      return;
    }
    await sync();
  }

  Future<void> sync() async {
    if (status == SyncStatus.syncing) {
      return;
    }
    _statusSubject.add(SyncStatus.syncing);
    final fileSystem = DocumentFileSystem.fromPlatform(remote: remoteStorage);
    if (fileSystem is! DocumentRemoteSystem) return;
    var files = <SyncFile>[];
    _filesSubject.add([]);
    final currentFiles = await fileSystem.getAllSyncFiles();
    _filesSubject.add(currentFiles);
    final now = DateTime.now().toUtc();

    final hasError = status == SyncStatus.error;

    for (final file in currentFiles) {
      switch (file.status) {
        case FileSyncStatus.localLatest:
          await fileSystem
              .uploadCachedContent(file.location.pathWithLeadingSlash);
          final syncedFile = SyncFile(
            isDirectory: file.isDirectory,
            location: file.location,
            syncedLastModified: now,
            localLastModified: file.localLastModified,
            remoteLastModified: file.localLastModified,
          );
          files.add(syncedFile);
          break;
        case FileSyncStatus.remoteLatest:
          if (!hasError) {
            await fileSystem.cache(file.location.pathWithLeadingSlash);
            final syncedFile = SyncFile(
              isDirectory: file.isDirectory,
              location: file.location,
              syncedLastModified: now,
              localLastModified: file.remoteLastModified,
              remoteLastModified: file.remoteLastModified,
            );
            files.add(syncedFile);
          }
          break;
        case FileSyncStatus.synced:
          files.add(file);
          break;
        case FileSyncStatus.conflict:
          _statusSubject.add(SyncStatus.error);
          files.add(file);
          break;
        case FileSyncStatus.offline:
          files.add(file);
          break;
      }
    }
    _filesSubject.add(files);
    if (status != SyncStatus.error) {
      await _updateLastSynced();
      _statusSubject.add(SyncStatus.synced);
    }
    _filesSubject.add(files);
  }

  Future<List<SyncFile>> getSyncFiles([FileSyncStatus? status]) async {
    // Get current files from stream or sync
    var currentFiles = await filesStream.first;
    if (status != null) {
      currentFiles =
          currentFiles.where((file) => file.status == status).toList();
    }
    return currentFiles;
  }

  void _onListen() {
    if (files == null) sync();
    _refreshSyncStatus();
  }

  Future<void> _updateLastSynced() {
    return settingsCubit.updateLastSynced(remoteStorage.identifier);
  }

  Future<void> resolve(String path, FileSyncStatus status) async {
    if (this.status == SyncStatus.syncing) {
      return;
    }
    _statusSubject.add(SyncStatus.syncing);
    final fileSystem = DocumentFileSystem.fromPlatform(remote: remoteStorage)
        as DavRemoteDocumentFileSystem;
    final last = List<SyncFile>.from(files ?? []);
    last.removeWhere(
        (element) => element.location.pathWithLeadingSlash == path);
    _filesSubject.add(last);
    switch (status) {
      case FileSyncStatus.localLatest:
        // Upload local file to remote
        await fileSystem.uploadCachedContent(path);
        await fileSystem.deleteCachedContent(path);
        break;
      case FileSyncStatus.remoteLatest:
        return fileSystem.deleteCachedContent(path);
      case FileSyncStatus.conflict:
        await fileSystem.cache(path);
        final remoteAsset = await fileSystem.fetchAsset(path, true, true).last;
        await remoteAsset?.maybeMap(
          file: (file) async {
            if (remoteAsset is! AppDocumentFile) return;
            final parent = path.substring(0, path.lastIndexOf('/'));
            final doc = file.load();
            await fileSystem.importDocument(doc, path: parent, forceSync: true);
            await fileSystem.uploadCachedContent(path);
          },
          orElse: () {},
        );
        break;
      default:
        _statusSubject.add(SyncStatus.error);
        throw Exception('Unknown status $status');
    }
    _statusSubject.add(SyncStatus.synced);

    await sync();
  }
}
