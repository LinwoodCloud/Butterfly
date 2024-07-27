import 'dart:typed_data';

import 'package:butterfly/api/file_system.dart';
import 'package:butterfly/api/save.dart';
import 'package:butterfly/cubits/settings.dart';
import 'package:butterfly/dialogs/file_system/move.dart';
import 'package:butterfly/services/sync.dart';
import 'package:butterfly/visualizer/connection.dart';
import 'package:butterfly_api/butterfly_api.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lw_file_system/lw_file_system.dart';
import 'package:material_leap/material_leap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class FileEntityGridItem extends StatelessWidget {
  final String? modifiedText, createdText;
  final bool active, editable, collapsed;
  final bool? selected;
  final PhosphorIconData icon;
  final VoidCallback onTap, onDelete, onReload;
  final ValueChanged<bool> onEdit, onSelectedChanged;
  final Uint8List? thumbnail;
  final FileSystemEntity<NoteData> entity;
  final TextEditingController nameController;

  const FileEntityGridItem({
    super.key,
    this.createdText,
    this.modifiedText,
    this.selected = false,
    this.active = false,
    this.editable = false,
    this.collapsed = false,
    required this.icon,
    required this.onTap,
    required this.onDelete,
    required this.onReload,
    required this.onEdit,
    required this.onSelectedChanged,
    this.thumbnail,
    required this.entity,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fileSystem = context.read<ButterflyFileSystem>();
    final syncService = context.read<SyncService>();
    final remote = fileSystem.settingsCubit.getRemote(entity.location.remote);
    final documentSystem = fileSystem.buildDocumentSystem(remote);
    final leading = PhosphorIcon(
      icon,
      color: colorScheme.outline,
      size: 48,
    );
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: active
            ? BorderSide(
                color: colorScheme.primaryContainer,
                width: 1,
              )
            : BorderSide.none,
      ),
      surfaceTintColor: active
          ? colorScheme.primaryContainer
          : colorScheme.secondaryContainer,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        highlightColor: active ? colorScheme.primaryContainer : null,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          width: 160,
          height: 192,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Center(
                    child: SizedBox(
                      height: 64,
                      width: 64,
                      child: thumbnail != null
                          ? Image.memory(
                              thumbnail!,
                              fit: BoxFit.contain,
                              cacheWidth: 64,
                              cacheHeight: 64,
                              errorBuilder: (context, error, stackTrace) =>
                                  leading,
                            )
                          : leading,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: FilesActionMenu(
                      remote: remote,
                      syncService: syncService,
                      entity: entity,
                      settingsCubit: fileSystem.settingsCubit,
                      editable: editable,
                      onEdit: onEdit,
                      nameController: nameController,
                      onDelete: onDelete,
                      onReload: onReload,
                      documentSystem: documentSystem,
                      onSelect: selected == null
                          ? () => onSelectedChanged(true)
                          : null,
                    ),
                  ),
                  if (selected != null)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Checkbox(
                        value: selected,
                        onChanged: (value) => onSelectedChanged(value ?? false),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 16,
                      child: modifiedText != null
                          ? Tooltip(
                              message: AppLocalizations.of(context).modified,
                              child: Row(
                                children: [
                                  PhosphorIcon(
                                    PhosphorIconsLight.clockCounterClockwise,
                                    size: 12,
                                    color: colorScheme.outline,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    modifiedText!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: colorScheme.outline,
                                        ),
                                  ),
                                ],
                              ),
                            )
                          : null,
                    ),
                    SizedBox(
                      height: 16,
                      child: createdText != null
                          ? Tooltip(
                              message: AppLocalizations.of(context).created,
                              child: Row(
                                children: [
                                  PhosphorIcon(
                                    PhosphorIconsLight.plus,
                                    size: 12,
                                    color: colorScheme.outline,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    createdText!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: colorScheme.outline,
                                        ),
                                  ),
                                ],
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 32,
                      child: editable
                          ? ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 200,
                              ),
                              child: TextField(
                                controller: nameController,
                                autofocus: true,
                                style: Theme.of(context).textTheme.labelLarge,
                                onSubmitted: (value) async {
                                  await documentSystem.renameAsset(
                                      entity.location.path, value);
                                  onEdit(false);
                                  onReload();
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  hintText:
                                      AppLocalizations.of(context).enterText,
                                  suffix: IconButton(
                                    onPressed: () async {
                                      await documentSystem.renameAsset(
                                          entity.location.path,
                                          nameController.text);
                                      onEdit(false);
                                      onReload();
                                    },
                                    icon: const PhosphorIcon(
                                        PhosphorIconsLight.check),
                                    tooltip: AppLocalizations.of(context).save,
                                  ),
                                ),
                              ))
                          : Align(
                              alignment: Alignment.centerLeft,
                              child: Tooltip(
                                message: entity.fileName,
                                child: GestureDetector(
                                  child: Text(
                                    entity.fileName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.labelLarge,
                                  ),
                                  onDoubleTap: () {
                                    onEdit(true);
                                    nameController.text = entity.fileName;
                                  },
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilesActionMenu extends StatelessWidget {
  const FilesActionMenu({
    super.key,
    required this.remote,
    required this.syncService,
    required this.entity,
    required this.settingsCubit,
    required this.editable,
    required this.onEdit,
    required this.nameController,
    required this.onDelete,
    required this.documentSystem,
    required this.onReload,
    this.onSelect,
  });

  final ExternalStorage? remote;
  final SyncService syncService;
  final DocumentFileSystem documentSystem;
  final FileSystemEntity<NoteData> entity;
  final SettingsCubit settingsCubit;
  final bool editable;
  final ValueChanged<bool> onEdit;
  final VoidCallback onReload, onDelete;
  final VoidCallback? onSelect;
  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder: defaultMenuButton(
        tooltip: AppLocalizations.of(context).actions,
      ),
      menuChildren: [
        if (remote is RemoteStorage)
          StreamBuilder<List<SyncFile>>(
            stream: syncService.getSync(remote!.identifier)?.filesStream,
            builder: (context, snapshot) {
              final currentStatus = snapshot.data
                  ?.lastWhereOrNull((element) => entity
                      .location.pathWithLeadingSlash
                      .startsWith(element.location.pathWithLeadingSlash))
                  ?.status;
              return MenuItemButton(
                leadingIcon: PhosphorIcon(currentStatus.getIcon(),
                    color:
                        currentStatus.getColor(Theme.of(context).colorScheme)),
                child: Text(currentStatus.getLocalizedName(context)),
                onPressed: () {
                  syncService.getSync(remote!.identifier)?.sync();
                },
              );
            },
          ),
        BlocBuilder<SettingsCubit, ButterflySettings>(
            builder: (context, state) {
          final starred = state.isStarred(entity.location);
          return MenuItemButton(
            onPressed: () {
              settingsCubit.toggleStarred(entity.location);
            },
            leadingIcon: starred
                ? const PhosphorIcon(PhosphorIconsFill.star)
                : const PhosphorIcon(PhosphorIconsLight.star),
            child: Text(starred
                ? AppLocalizations.of(context).unstar
                : AppLocalizations.of(context).star),
          );
        }),
        if (onSelect != null)
          MenuItemButton(
            onPressed: onSelect,
            leadingIcon: const PhosphorIcon(PhosphorIconsLight.check),
            child: Text(AppLocalizations.of(context).select),
          ),
        MenuItemButton(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => FileSystemAssetMoveDialog(
              asset: entity,
              fileSystem: documentSystem,
            ),
          ).then((value) => onReload()),
          leadingIcon: const PhosphorIcon(PhosphorIconsLight.arrowsDownUp),
          child: Text(AppLocalizations.of(context).move),
        ),
        if (!editable)
          MenuItemButton(
            onPressed: () {
              onEdit(true);
              nameController.text = entity.fileName;
            },
            leadingIcon: const PhosphorIcon(PhosphorIconsLight.pencil),
            child: Text(AppLocalizations.of(context).rename),
          ),
        if (entity is FileSystemFile<NoteData>)
          MenuItemButton(
            onPressed: () {
              try {
                final data = (entity as FileSystemFile<NoteData>).data;
                exportData(context, data?.save() ?? []);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context).error,
                    ),
                  ),
                );
              }
            },
            leadingIcon: const PhosphorIcon(PhosphorIconsLight.paperPlaneRight),
            child: Text(AppLocalizations.of(context).export),
          ),
        MenuItemButton(
          onPressed: onDelete,
          leadingIcon: const PhosphorIcon(PhosphorIconsLight.trash),
          child: Text(AppLocalizations.of(context).delete),
        ),
      ],
    );
  }
}
