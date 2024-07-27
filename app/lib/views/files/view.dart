import 'dart:typed_data';

import 'package:butterfly/api/file_system.dart';
import 'package:butterfly/models/defaults.dart';
import 'package:butterfly/views/files/card.dart';
import 'package:butterfly/views/files/entity.dart';
import 'package:butterfly/widgets/connection_button.dart';
import 'package:butterfly_api/butterfly_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:lw_file_system/lw_file_system.dart';
import 'package:material_leap/material_leap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../api/open.dart';
import '../../cubits/settings.dart';
import '../../dialogs/file_system/sync.dart';
import '../../dialogs/name.dart';
import '../../services/import.dart';

class FilesView extends StatefulWidget {
  final AssetLocation? activeAsset;
  final ExternalStorage? remote;
  final ValueChanged<ExternalStorage?>? onRemoteChanged;
  final bool collapsed;
  final bool isMobile;

  const FilesView({
    super.key,
    this.activeAsset,
    this.remote,
    this.onRemoteChanged,
    this.collapsed = false,
    this.isMobile = false,
  });

  @override
  State<FilesView> createState() => FilesViewState();
}

class FilesViewState extends State<FilesView> {
  final TextEditingController _locationController = TextEditingController();
  late final ButterflyFileSystem _fileSystem;
  late DocumentFileSystem _documentSystem;
  late TemplateFileSystem _templateSystem;

  SortBy _sortBy = SortBy.name;
  SortOrder _sortOrder = SortOrder.ascending;
  ExternalStorage? _remote;
  String _search = '';
  late final SettingsCubit _settingsCubit;
  Stream<FileSystemEntity<NoteData>?>? _filesStream;
  final List<String> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _fileSystem = context.read<ButterflyFileSystem>();
    _settingsCubit = context.read<SettingsCubit>();
    _sortBy = _settingsCubit.state.sortBy;
    _sortOrder = _settingsCubit.state.sortOrder;
    _remote = widget.remote ?? _settingsCubit.getRemote();
    _setFilesStream();
  }

  @override
  void didUpdateWidget(covariant FilesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.remote != widget.remote) {
      _remote = widget.remote;
      _setFilesStream();
    }
  }

  String getLocalizedNameOfSortBy(SortBy sortBy) => switch (sortBy) {
        SortBy.name => AppLocalizations.of(context).name,
        SortBy.created => AppLocalizations.of(context).created,
        SortBy.modified => AppLocalizations.of(context).modified,
      };

  IconGetter getIconOfSortBy(SortBy sortBy) => switch (sortBy) {
        SortBy.name => PhosphorIcons.file,
        SortBy.created => PhosphorIcons.calendar,
        SortBy.modified => PhosphorIcons.clock,
      };

  void _setFilesStream() {
    _templateSystem = _fileSystem.buildTemplateSystem(_remote);
    _documentSystem = _fileSystem.buildDocumentSystem(_remote);
    _filesStream = _documentSystem.fetchAsset(_locationController.text);
  }

  void reloadFileSystem() {
    if (mounted) {
      setState(_setFilesStream);
    }
  }

  Future<void> _createFile(NoteData? template) async {
    template ??= await DocumentDefaults.createTemplate();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => NameDialog(
        validator: defaultFileNameValidator(context),
      ),
    );
    if (name == null) return;
    final path = _locationController.text;
    final newPath = '$path/${_documentSystem.convertNameToFile(name)}.bfly';
    await _documentSystem.updateFile(
        newPath,
        template.createDocument(
          name: name,
        ));
    reloadFileSystem();
  }

  void _setRemote(ExternalStorage? remote) {
    setState(() => _remote = remote);
    _setFilesStream();
    widget.onRemoteChanged?.call(remote);
  }

  void Function(bool) _updateSelection(String path) => (bool value) {
        setState(() {
          if (value) {
            _selectedFiles.add(path);
          } else {
            _selectedFiles.remove(path);
          }
        });
      };

  @override
  Widget build(BuildContext context) {
    final index = _locationController.text.lastIndexOf('/');
    final parent = _locationController.text.substring(0, index < 0 ? 0 : index);
    return BlocBuilder<SettingsCubit, ButterflySettings>(
      buildWhen: (previous, current) => previous.gridView != current.gridView,
      builder: (context, state) =>
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        LayoutBuilder(builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;
          final text = Text(
            AppLocalizations.of(context).files,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.start,
          );
          final orderButton = IconButton(
            icon: PhosphorIcon(_sortOrder == SortOrder.ascending
                ? PhosphorIconsLight.sortAscending
                : PhosphorIconsLight.sortDescending),
            tooltip: _sortOrder == SortOrder.ascending
                ? AppLocalizations.of(context).ascending
                : AppLocalizations.of(context).descending,
            onPressed: () => setState(() {
              _sortOrder = _sortOrder == SortOrder.ascending
                  ? SortOrder.descending
                  : SortOrder.ascending;
              _settingsCubit.changeSortOrder(_sortOrder);
            }),
          );
          final desktopActions = OverflowBar(
            spacing: 8,
            overflowSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context).switchView),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () =>
                        context.read<SettingsCubit>().toggleGridView(),
                    icon: state.gridView
                        ? const PhosphorIcon(PhosphorIconsLight.list)
                        : const PhosphorIcon(PhosphorIconsLight.gridFour),
                  ),
                ],
              ),
              BlocBuilder<SettingsCubit, ButterflySettings>(
                buildWhen: (previous, current) =>
                    previous.connections != current.connections,
                builder: (context, state) => Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DropdownMenu<String?>(
                      label: Text(AppLocalizations.of(context).source),
                      width: 225,
                      dropdownMenuEntries: [
                        DropdownMenuEntry(
                          value: null,
                          label: AppLocalizations.of(context).local,
                        ),
                        ...state.connections.map((e) => DropdownMenuEntry(
                              value: e.identifier,
                              label: e.label,
                            )),
                      ],
                      initialSelection: _remote?.identifier,
                      onSelected: (value) => _setRemote(
                          value == null ? null : state.getRemote(value)),
                    ),
                    state.connections.any((e) => e is RemoteStorage)
                        ? const SyncButton()
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
              DropdownMenu<SortBy>(
                leadingIcon: orderButton,
                label: Text(AppLocalizations.of(context).sortBy),
                width: 225,
                dropdownMenuEntries: SortBy.values
                    .map((e) => DropdownMenuEntry(
                          value: e,
                          label: getLocalizedNameOfSortBy(e),
                          leadingIcon: PhosphorIcon(
                              getIconOfSortBy(e)(PhosphorIconsStyle.light)),
                        ))
                    .toList(),
                initialSelection: _sortBy,
                onSelected: (value) => setState(() {
                  _sortBy = value ?? _sortBy;
                  _settingsCubit.changeSortBy(_sortBy);
                }),
              ),
            ],
          );
          final primary = Theme.of(context).colorScheme.primary;
          final mobileActions = OverflowBar(
            spacing: 4,
            overflowSpacing: 4,
            children: [
              if (!widget.collapsed)
                IconButton(
                  onPressed: () =>
                      context.read<SettingsCubit>().toggleGridView(),
                  tooltip: AppLocalizations.of(context).switchView,
                  icon: state.gridView
                      ? const PhosphorIcon(PhosphorIconsLight.list)
                      : const PhosphorIcon(PhosphorIconsLight.gridFour),
                ),
              ConnectionButton(
                currentRemote: _remote?.identifier ?? '',
                onChanged: _setRemote,
              ),
              MenuAnchor(
                builder: defaultMenuButton(
                  tooltip: AppLocalizations.of(context).sortBy,
                  icon: PhosphorIcon(
                      getIconOfSortBy(_sortBy)(PhosphorIconsStyle.light)),
                ),
                menuChildren: SortBy.values
                    .map((e) => MenuItemButton(
                          leadingIcon: PhosphorIcon(
                              getIconOfSortBy(e)(PhosphorIconsStyle.light),
                              color: e == _sortBy ? primary : null),
                          child: Text(getLocalizedNameOfSortBy(e),
                              style: e == _sortBy
                                  ? TextStyle(color: primary)
                                  : null),
                          onPressed: () => setState(() {
                            _sortBy = e;
                            _settingsCubit.changeSortBy(_sortBy);
                          }),
                        ))
                    .toList(),
              ),
              orderButton,
            ],
          );
          if (widget.collapsed) {
            return Center(child: mobileActions);
          }
          return OverflowBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              text,
              isDesktop ? desktopActions : mobileActions,
            ],
          );
        }),
        const SizedBox(height: 8),
        _RecentFilesView(
          replace: widget.collapsed,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, constraints) {
          final searchBar = Row(children: [
            IconButton(
              onPressed: reloadFileSystem,
              tooltip: AppLocalizations.of(context).refresh,
              icon: const PhosphorIcon(PhosphorIconsLight.arrowClockwise),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SearchBar(
                onChanged: (value) => setState(() => _search = value),
                hintText: AppLocalizations.of(context).search,
                leading: const PhosphorIcon(PhosphorIconsLight.magnifyingGlass),
              ),
            ),
          ]);
          final locationBar = SizedBox(
            height: 64,
            child: _selectedFiles.isEmpty
                ? BlocBuilder<SettingsCubit, ButterflySettings>(
                    buildWhen: (previous, current) =>
                        previous.flags != current.flags,
                    builder: (context, settings) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MenuAnchor(
                          menuChildren: [
                            MenuItemButton(
                              leadingIcon:
                                  const PhosphorIcon(PhosphorIconsLight.folder),
                              child:
                                  Text(AppLocalizations.of(context).newFolder),
                              onPressed: () async {
                                final name = await showDialog<String>(
                                  context: context,
                                  builder: (context) => NameDialog(
                                    validator:
                                        defaultFileNameValidator(context),
                                  ),
                                );
                                if (name == null) return;
                                final path = _locationController.text;
                                final newPath = '$path/$name';
                                await _documentSystem.createDirectory(newPath);
                                reloadFileSystem();
                              },
                            ),
                            MenuItemButton(
                              onPressed: () async => _createFile(
                                await _templateSystem.getDefaultFile(
                                  _templateSystem
                                          .storage?.defaults['template'] ??
                                      _settingsCubit.state.defaultTemplate,
                                ),
                              ),
                              leadingIcon: const PhosphorIcon(
                                  PhosphorIconsLight.filePlus),
                              child: Text(AppLocalizations.of(context).newFile),
                            ),
                            FutureBuilder<Map<String, NoteData>>(
                              future: _templateSystem
                                  .initialize()
                                  .then((_) => _templateSystem.getFiles()),
                              builder: (context, snapshot) => SubmenuButton(
                                leadingIcon:
                                    const PhosphorIcon(PhosphorIconsLight.file),
                                menuChildren: snapshot.data?.values.map((e) {
                                      final metadata = e.getMetadata();
                                      final thumbnail = e.getThumbnail();
                                      return MenuItemButton(
                                        leadingIcon: thumbnail == null
                                            ? null
                                            : Image.memory(
                                                thumbnail,
                                                width: 32,
                                                height: 18,
                                                cacheWidth: 32,
                                                cacheHeight: 18,
                                              ),
                                        child: Text(metadata?.name ?? ''),
                                        onPressed: () => _createFile(e),
                                      );
                                    }).toList() ??
                                    [],
                                child: Text(
                                    AppLocalizations.of(context).templates),
                              ),
                            ),
                            MenuItemButton(
                              leadingIcon: const PhosphorIcon(
                                  PhosphorIconsLight.arrowSquareIn),
                              onPressed: () async {
                                final router = GoRouter.of(context);
                                final importService =
                                    context.read<ImportService>();
                                final (result, extension) =
                                    await importFile(context);
                                if (result == null) return;
                                final model = await importService.import(
                                  AssetFileTypeHelper.fromFileExtension(
                                          extension) ??
                                      AssetFileType.note,
                                  result,
                                  advanced: false,
                                  fileSystem: _documentSystem,
                                  templateSystem: _templateSystem,
                                  packSystem:
                                      _fileSystem.buildPackSystem(_remote),
                                );
                                if (model == null) {
                                  reloadFileSystem();
                                  return;
                                }
                                const route =
                                    '/native?name=document.bfly&type=note';
                                router.go(route, extra: model.save());
                                if (!widget.collapsed) {
                                  reloadFileSystem();
                                }
                              },
                              child: Text(AppLocalizations.of(context).import),
                            ),
                            if (settings.hasFlag('collaboration'))
                              MenuItemButton(
                                leadingIcon: const PhosphorIcon(
                                    PhosphorIconsLight.shareNetwork),
                                child:
                                    Text(AppLocalizations.of(context).connect),
                                onPressed: () async {
                                  final url = await showDialog<String>(
                                    builder: (context) => NameDialog(
                                      title:
                                          AppLocalizations.of(context).enterUrl,
                                      hint: AppLocalizations.of(context).url,
                                      button:
                                          AppLocalizations.of(context).connect,
                                    ),
                                    context: context,
                                  );
                                  if (url == null) return;
                                  GoRouter.of(context)
                                      .pushNamed('connect', queryParameters: {
                                    'url': url,
                                  });
                                },
                              ),
                          ],
                          builder: (context, controller, child) =>
                              FloatingActionButton.small(
                            heroTag: null,
                            onPressed: controller.toggle,
                            tooltip: AppLocalizations.of(context).create,
                            child: const PhosphorIcon(PhosphorIconsLight.plus),
                          ),
                        ),
                        DragTarget<String>(
                          builder: (context, candidateData, rejectedData) =>
                              IconButton(
                            onPressed: _locationController.text.isEmpty
                                ? null
                                : () => setState(() {
                                      _locationController.text = parent;
                                      _setFilesStream();
                                    }),
                            icon:
                                const PhosphorIcon(PhosphorIconsLight.arrowUp),
                            tooltip: AppLocalizations.of(context).goUp,
                          ),
                          onWillAcceptWithDetails: (data) => true,
                          onAcceptWithDetails: (data) async {
                            await _documentSystem.moveAsset(data.data,
                                '$parent/${data.data.split('/').last}');
                            reloadFileSystem();
                          },
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context).location,
                              prefixIcon:
                                  const PhosphorIcon(PhosphorIconsLight.folder),
                              filled: true,
                            ),
                            controller: _locationController,
                            onFieldSubmitted: (value) => reloadFileSystem(),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const PhosphorIcon(
                                  PhosphorIconsLight.selectionSlash),
                              tooltip: AppLocalizations.of(context).deselect,
                              onPressed: () =>
                                  setState(() => _selectedFiles.clear()),
                            ),
                            Builder(builder: (context) {
                              return IconButton(
                                icon: const PhosphorIcon(
                                    PhosphorIconsLight.trash),
                                tooltip: AppLocalizations.of(context).delete,
                                onPressed: () async => deleteEntities(
                                  context: context,
                                  entities: _selectedFiles,
                                  documentSystem: _documentSystem,
                                  isMobile: widget.isMobile,
                                  onDelete: reloadFileSystem,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
          final isDesktop = constraints.maxWidth > 600;
          if (isDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: locationBar),
                const SizedBox(width: 8),
                SizedBox(width: 250, child: searchBar),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                searchBar,
                const SizedBox(height: 16),
                locationBar,
              ],
            );
          }
        }),
        BlocBuilder<SettingsCubit, ButterflySettings>(
          buildWhen: (previous, current) => previous.starred != current.starred,
          builder: (context, settings) =>
              StreamBuilder<FileSystemEntity<NoteData>?>(
                  stream: _filesStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData) {
                      return Text(AppLocalizations.of(context).noElements);
                    }
                    final entity = snapshot.data;
                    if (entity is! FileSystemDirectory<NoteData>) {
                      return Container();
                    }
                    final assets = entity.assets.where((e) {
                      if (_search.isNotEmpty) {
                        return e.fileName
                            .toLowerCase()
                            .contains(_search.toLowerCase());
                      }
                      return true;
                    }).toList()
                      ..sort(_sortAssets);
                    if (assets.isEmpty) {
                      return Center(
                        child: Text(AppLocalizations.of(context).noElements),
                      );
                    }
                    if (state.gridView && !widget.collapsed) {
                      return Center(
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: assets.map(
                            (e) {
                              final active =
                                  widget.activeAsset?.isSame(e.location) ??
                                      false;
                              return FileEntityItem(
                                entity: e,
                                isMobile: widget.isMobile,
                                active: active,
                                collapsed: widget.collapsed,
                                onTap: () => _onFileTap(e),
                                selected: _selectedFiles.isEmpty
                                    ? null
                                    : _selectedFiles.contains(e.location.path),
                                onSelected: _updateSelection(e.location.path),
                                onReload: reloadFileSystem,
                                gridView: true,
                              );
                            },
                          ).toList(),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: assets.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final e = assets[index];
                        final active =
                            widget.activeAsset?.isSame(e.location) ?? false;
                        return FileEntityItem(
                          entity: e,
                          active: active,
                          collapsed: widget.collapsed,
                          selected: _selectedFiles.isEmpty
                              ? null
                              : _selectedFiles.contains(e.location.path),
                          onTap: () => _onFileTap(e),
                          onSelected: _updateSelection(e.location.path),
                          onReload: reloadFileSystem,
                          gridView: false,
                          isMobile: widget.isMobile,
                        );
                      },
                    );
                  }),
        ),
      ]),
    );
  }

  Future<void> _onFileTap(FileSystemEntity entity) async {
    if (entity is! FileSystemFile) {
      setState(() {
        _locationController.text = entity.pathWithoutLeadingSlash;
        _setFilesStream();
      });
      return;
    }
    final location = entity.location;
    final data = entity.data;
    await openFile(context, widget.collapsed, location, data);
    if (!widget.collapsed) {
      reloadFileSystem();
    }
  }

  int _sortAssets(FileSystemEntity<NoteData> a, FileSystemEntity<NoteData> b) {
    try {
      final settings = _settingsCubit.state;
      // Test if starred
      final aStarred = settings.isStarred(a.location);
      final bStarred = settings.isStarred(b.location);
      if (aStarred && !bStarred) {
        return -1;
      }
      if (bStarred && !aStarred) {
        return 1;
      }
      if (a is FileSystemDirectory<NoteData>) {
        return -1;
      }
      if (b is FileSystemDirectory<NoteData>) {
        return 1;
      }
      final aFile = a as FileSystemFile<NoteData>;
      final bFile = b as FileSystemFile<NoteData>;
      FileMetadata? aInfo, bInfo;
      try {
        aInfo = aFile.data?.getMetadata();
      } catch (_) {}
      try {
        bInfo = bFile.data?.getMetadata();
      } catch (_) {}
      if (aInfo == null) {
        if (bInfo == null) {
          return aFile.fileName.compareTo(bFile.fileName);
        }
        return 1;
      }
      if (bInfo == null) {
        return -1;
      }
      switch (_sortBy) {
        case SortBy.name:
          final compared = aFile.fileName.compareTo(bFile.fileName);
          return _sortOrder == SortOrder.ascending ? compared : -compared;
        case SortBy.created:
          final aCreatedAt = aInfo.createdAt;
          final bCreatedAt = bInfo.createdAt;
          if (aCreatedAt == null) {
            return 1;
          }
          if (bCreatedAt == null) {
            return -1;
          }
          final compared = bCreatedAt.compareTo(aCreatedAt);
          return _sortOrder == SortOrder.ascending ? compared : -compared;
        case SortBy.modified:
          final aModifiedAt = aInfo.updatedAt;
          final bModifiedAt = bInfo.updatedAt;
          if (aModifiedAt == null) {
            return 1;
          }
          if (bModifiedAt == null) {
            return -1;
          }
          final compared = bModifiedAt.compareTo(aModifiedAt);
          return _sortOrder == SortOrder.ascending ? compared : -compared;
      }
    } catch (e) {
      return 0;
    }
  }
}

class _RecentFilesView extends StatefulWidget {
  final bool replace;
  const _RecentFilesView({
    required this.replace,
  });

  @override
  State<_RecentFilesView> createState() => _RecentFilesViewState();
}

class _RecentFilesViewState extends State<_RecentFilesView> {
  late Stream<List<FileSystemEntity<NoteData>>> _stream;
  late final ButterflyFileSystem _fileSystem;
  final ScrollController _recentScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fileSystem = context.read<ButterflyFileSystem>();
    _setStream(context.read<SettingsCubit>().state);
  }

  @override
  void dispose() {
    _recentScrollController.dispose();
    super.dispose();
  }

  void _setStream(ButterflySettings settings) =>
      _stream = GeneralDirectoryFileSystem.fetchAssetsGlobalSync(
          settings.history, _fileSystem.buildAllDocumentSystems());

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, ButterflySettings>(
      listenWhen: (previous, current) => previous.history != current.history,
      listener: (_, state) => setState(() {
        _setStream(state);
      }),
      child: StreamBuilder<List<FileSystemEntity>>(
          stream: _stream,
          builder: (context, snapshot) {
            final files = snapshot.data ?? [];
            if (files.isEmpty) {
              return Container();
            }
            return SizedBox(
              height: 128,
              child: Scrollbar(
                controller: _recentScrollController,
                child: ListView.builder(
                  controller: _recentScrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final entity = files[index];
                    FileMetadata? metadata;
                    Uint8List? thumbnail;
                    if (entity is FileSystemFile<NoteData>) {
                      metadata = entity.data?.getMetadata();
                      thumbnail = entity.data?.getThumbnail();
                    }
                    return AssetCard(
                      metadata: metadata,
                      thumbnail: thumbnail,
                      name: entity.location.identifier,
                      height: double.infinity,
                      onTap: () =>
                          openFile(context, widget.replace, entity.location),
                    );
                  },
                ),
              ),
            );
          }),
    );
  }
}
