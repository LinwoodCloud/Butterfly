import 'package:butterfly/actions/new.dart';
import 'package:butterfly/cubits/settings.dart';
import 'package:butterfly/widgets/remote_button.dart';
import 'package:butterfly/widgets/responsive_dialog.dart';
import 'package:butterfly_api/butterfly_api.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_leap/material_leap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../api/file_system/file_system.dart';
import '../bloc/document_bloc.dart';
import '../widgets/editable_list_tile.dart';
import 'delete.dart';

class TemplateDialog extends StatefulWidget {
  final DocumentBloc? bloc;
  const TemplateDialog({super.key, this.bloc});

  @override
  State<TemplateDialog> createState() => _TemplateDialogState();
}

class _TemplateDialogState extends State<TemplateDialog> {
  late TemplateFileSystem _fileSystem;
  Future<List<NoteData>>? _templatesFuture;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedTemplates = [];

  @override
  void initState() {
    super.initState();
    _fileSystem =
        context.read<SettingsCubit>().state.getDefaultTemplateFileSystem();
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  void load() {
    setState(() {
      _templatesFuture = _fileSystem.createDefault(context).then((value) async {
        var templates = await _fileSystem.getTemplates();
        templates = templates
            .where((element) =>
                element.name
                    ?.toLowerCase()
                    .contains(_searchController.text.toLowerCase()) ??
                true)
            .toList();
        return templates;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialog(
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
            child: Column(
              children: [
                Header(
                  title: Text(AppLocalizations.of(context).templates),
                  leading: IconButton.outlined(
                    icon: const PhosphorIcon(PhosphorIconsLight.x),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: AppLocalizations.of(context).close,
                  ),
                  actions: [
                    RemoteButton(
                      currentRemote: _fileSystem.remote?.identifier ?? '',
                      onChanged: (value) {
                        _fileSystem =
                            TemplateFileSystem.fromPlatform(remote: value);
                        load();
                      },
                    ),
                    IconButton(
                      icon: const PhosphorIcon(
                          PhosphorIconsLight.clockCounterClockwise),
                      tooltip: AppLocalizations.of(context).defaultTemplate,
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                                AppLocalizations.of(context).defaultTemplate),
                            content:
                                Text(AppLocalizations.of(context).reallyReset),
                            actions: [
                              TextButton(
                                child:
                                    Text(AppLocalizations.of(context).cancel),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              ElevatedButton(
                                child: Text(AppLocalizations.of(context).ok),
                                onPressed: () async {
                                  for (final template
                                      in await _fileSystem.getTemplates()) {
                                    _fileSystem.deleteTemplate(template.name!);
                                  }
                                  if (context.mounted) {
                                    await _fileSystem.createDefault(
                                        this.context,
                                        force: true);
                                  }
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                    load();
                                    setState(() {});
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    ...widget.bloc == null
                        ? []
                        : [
                            IconButton(
                              onPressed: () => _showCreateDialog(widget.bloc!),
                              tooltip: AppLocalizations.of(context).create,
                              icon: const PhosphorIcon(PhosphorIconsLight.plus),
                            )
                          ],
                  ],
                ),
                Flexible(
                  child: FutureBuilder<List<NoteData>>(
                      future: _templatesFuture, builder: _buildBody),
                ),
              ],
            )));
  }

  Widget _buildBody(
      BuildContext context, AsyncSnapshot<List<NoteData>> snapshot) {
    if (snapshot.hasError) {
      return Text(snapshot.error.toString());
    }
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    var templates = snapshot.data!;
    return Stack(children: [
      ListView.builder(
          itemCount: templates.length,
          padding: const EdgeInsets.only(
            top: 64,
            bottom: 32,
            left: 8,
            right: 8,
          ),
          itemBuilder: (context, index) {
            var template = templates[index];
            return _TemplateItem(
              template: template,
              fileSystem: _fileSystem,
              replace: widget.bloc != null,
              selected: _selectedTemplates.contains(template.name),
              onSelected: () {
                setState(() {
                  _selectedTemplates.add(template.name!);
                });
              },
              onUnselected: () {
                setState(() {
                  _selectedTemplates.remove(template.name);
                });
              },
              onChanged: () {
                load();
                setState(() {});
              },
            );
          }),
      Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SearchBar(
            leading: const PhosphorIcon(PhosphorIconsLight.magnifyingGlass),
            constraints: const BoxConstraints(maxWidth: 500, minHeight: 50),
            controller: _searchController,
            hintText: AppLocalizations.of(context).search,
            onChanged: (value) async {
              load();
              setState(() {});
            },
          ),
        ),
      ),
      if (_selectedTemplates.isNotEmpty)
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const PhosphorIcon(
                          PhosphorIconsLight.selectionInverse),
                      tooltip: AppLocalizations.of(context).invertSelection,
                      onPressed: () {
                        setState(() {
                          final inverted = templates
                              .map((e) => e.name!)
                              .toSet()
                              .difference(_selectedTemplates.toSet());
                          _selectedTemplates.clear();
                          _selectedTemplates.addAll(inverted);
                        });
                      },
                    ),
                    Row(
                      children: [
                        if (widget.bloc != null)
                          IconButton(
                            icon: const PhosphorIcon(PhosphorIconsLight.wrench),
                            tooltip: AppLocalizations.of(context).overrideTools,
                            onPressed: () async {
                              final state = widget.bloc!.state;
                              if (state is! DocumentLoaded) return;
                              final tools = state.info.tools;
                              for (final name in _selectedTemplates) {
                                var template = templates.firstWhereOrNull(
                                    (element) => element.name == name);
                                if (template == null) continue;
                                final info = template.getInfo();
                                if (info == null) continue;
                                template = template
                                    .setInfo(info.copyWith(tools: tools));
                                await _fileSystem.updateTemplate(template);
                              }
                              setState(() {
                                _selectedTemplates.clear();
                              });
                            },
                          ),
                        IconButton(
                          icon: const PhosphorIcon(PhosphorIconsLight.trash),
                          tooltip: AppLocalizations.of(context).delete,
                          onPressed: () async {
                            final result = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => const DeleteDialog());
                            if (result != true) return;
                            for (final template in _selectedTemplates) {
                              await _fileSystem.deleteTemplate(template);
                            }
                            _selectedTemplates.clear();
                            load();
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    ]);
  }

  Future<void> _showCreateDialog(DocumentBloc bloc) {
    final state = bloc.state;
    var initialName = '';
    if (state is DocumentLoaded) {
      initialName = state.metadata.name;
    }
    final nameController = TextEditingController(text: initialName),
        directoryController = TextEditingController();
    return showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context).createTemplate),
            scrollable: true,
            content: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context).createTemplateContent),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).name,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: directoryController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).directory,
                      filled: true,
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context).cancel),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: Text(AppLocalizations.of(context).create),
                onPressed: () async {
                  bloc.createTemplate(
                    _fileSystem.remote?.identifier,
                    name: nameController.text,
                    directory: directoryController.text,
                  );
                  Navigator.of(context).pop();
                  load();
                  setState(() {});
                },
              ),
            ],
          );
        });
  }
}

class _TemplateItem extends StatelessWidget {
  final NoteData template;
  final TemplateFileSystem fileSystem;
  final VoidCallback onChanged, onSelected, onUnselected;
  final bool replace, selected;

  const _TemplateItem({
    required this.template,
    required this.fileSystem,
    required this.onChanged,
    required this.replace,
    required this.selected,
    required this.onSelected,
    required this.onUnselected,
  });

  @override
  Widget build(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>();
    final settings = settingsCubit.state;
    final isDefault = settings.defaultTemplate == template.name;
    final metadata = template.getMetadata();
    if (metadata == null) {
      return const SizedBox();
    }
    final thumbnail = template.getThumbnail();
    const leading = PhosphorIcon(
      PhosphorIconsLight.file,
      size: 48,
    );
    return EditableListTile(
      initialValue: metadata.name,
      subtitle: Text(metadata.description),
      leading: SizedBox(
        height: 64,
        width: 96,
        child: Row(
          children: [
            Checkbox(
              value: selected,
              onChanged: (value) {
                if (value == true) {
                  onSelected();
                } else {
                  onUnselected();
                }
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: thumbnail != null
                  ? Image.memory(
                      thumbnail,
                      fit: BoxFit.contain,
                      cacheWidth: 64,
                      cacheHeight: 64,
                      errorBuilder: (context, error, stackTrace) => leading,
                    )
                  : leading,
            ),
          ],
        ),
      ),
      onSaved: (value) async {
        if (value == metadata.name) return;
        await fileSystem.renameTemplate(metadata.name, value);
        onChanged();
      },
      actions: [
        CheckboxMenuButton(
          value: isDefault,
          child: Text(AppLocalizations.of(context).defaultTemplate),
          onChanged: (value) async {
            final name = metadata.name;
            settingsCubit.changeDefaultTemplate(name);
            Navigator.of(context).pop();
            onChanged();
          },
        ),
        MenuItemButton(
          leadingIcon: const PhosphorIcon(PhosphorIconsLight.trash),
          child: Text(AppLocalizations.of(context).delete),
          onPressed: () async {
            Navigator.of(context).pop();
            final result = await showDialog<bool>(
                context: context, builder: (ctx) => const DeleteDialog());
            if (result != true) return;
            if (context.mounted) {
              await fileSystem.deleteTemplate(metadata.name);
              onChanged();
            }
          },
        ),
      ],
      onTap: () => openNewDocument(
          context, replace, template, fileSystem.remote?.identifier),
    );
  }
}
