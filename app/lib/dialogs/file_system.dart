import 'dart:async';

import 'package:butterfly/api/file_system.dart';
import 'package:butterfly/bloc/document_bloc.dart';
import 'package:butterfly/models/document.dart';
import 'package:butterfly/models/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class FileSystemDialog extends StatefulWidget {
  final DocumentBloc bloc;

  const FileSystemDialog({Key? key, required this.bloc}) : super(key: key);

  @override
  _FileSystemDialogState createState() => _FileSystemDialogState();
}

class _FileSystemDialogState extends State<FileSystemDialog> {
  List<AppDocumentAsset> _documents = [];
  bool gridView = true;
  late DocumentFileSystem _fileSystem;
  final GlobalKey<FormState> _createFormKey = GlobalKey();

  @override
  void initState() {
    _fileSystem = DocumentFileSystem.fromPlatform();
    loadDocuments();
    super.initState();
  }

  Future<void> loadDocuments() async {
    var documents =
        await _fileSystem.getRootDirectory().then((value) => value.assets);
    setState(() => _documents = documents);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 800),
          child: Scaffold(
            appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.open),
                leading: IconButton(
                  icon: const Icon(PhosphorIcons.xLight),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                      icon: Icon(gridView
                          ? PhosphorIcons.listLight
                          : PhosphorIcons.gridFourLight),
                      onPressed: () => setState(() => gridView = !gridView)),
                ]),
            body: gridView ? _buildGridView() : _buildListView(),
            floatingActionButton: FloatingActionButton.extended(
              label: Text(AppLocalizations.of(context)!.create),
              icon: const Icon(PhosphorIcons.plusLight),
              onPressed: () {
                var _nameController = TextEditingController();
                showDialog(
                    context: context,
                    builder: (context) => Form(
                          key: _createFormKey,
                          child: AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            title: Text(AppLocalizations.of(context)!.create),
                            content: TextFormField(
                              decoration: InputDecoration(
                                  filled: true,
                                  labelText:
                                      AppLocalizations.of(context)!.name),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return AppLocalizations.of(context)!
                                      .shouldNotEmpty;
                                }
                                return null;
                              },
                              controller: _nameController,
                              autofocus: true,
                            ),
                            actions: [
                              TextButton(
                                child:
                                    Text(AppLocalizations.of(context)!.cancel),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              TextButton(
                                child:
                                    Text(AppLocalizations.of(context)!.create),
                                onPressed: () async {
                                  if (_createFormKey.currentState?.validate() ??
                                      false) {
                                    await _fileSystem.createDocument(
                                        _nameController.text,
                                        palettes:
                                            ColorPalette.getMaterialPalette(
                                                context));
                                    loadDocuments();
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                            ],
                          ),
                        ));
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView() => ListView.builder(
        itemCount: _documents.length,
        itemBuilder: (context, index) {
          var document = _documents[index];
          if (document is AppDocumentFile) {
            return ListTile(
              title: Text(document.name),
              subtitle: _buildRichText(document),
              onTap: () => _openDocument(document.path),
              trailing: _buildPopupMenu(document),
            );
          } else if (document is AppDocumentDirectory) {
            return ListTile(
              title: Text(document.path.split('/').last),
            );
          } else {
            return Container();
          }
        },
      );

  void _openDocument(String path) => Navigator.of(context).pop(path);

  void _renameDialog(String path) {
    var _nameController = TextEditingController(text: path);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.rename),
              content: TextFormField(
                decoration: InputDecoration(
                    filled: true,
                    labelText: AppLocalizations.of(context)!.name),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return AppLocalizations.of(context)!.shouldNotEmpty;
                  }
                  return null;
                },
                controller: _nameController,
                autofocus: true,
              ),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context)!.cancel),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text(AppLocalizations.of(context)!.rename),
                  onPressed: () async {
                    if (_nameController.text != path) {
                      var document = await _fileSystem.renameAsset(
                          path, _nameController.text);
                      var state = widget.bloc.state as DocumentLoadSuccess;
                      if (document != null && state.path == path) {
                        widget.bloc.clearHistory();
                        widget.bloc.emit(state.copyWith(path: document.path));
                      }
                      loadDocuments();
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  void _deleteDialog(String path) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.areYouSure),
            content: Text(AppLocalizations.of(context)!.reallyDelete),
            actions: [
              TextButton(
                child: Text(AppLocalizations.of(context)!.no),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(AppLocalizations.of(context)!.yes),
                onPressed: () {
                  _fileSystem.deleteAsset(path);
                  loadDocuments();
                  Navigator.of(context).pop();
                },
              )
            ],
          ));

  Widget _buildGridView() => SingleChildScrollView(
      child: Align(
          alignment: Alignment.topCenter,
          child: Wrap(
              alignment: WrapAlignment.center,
              children: List.generate(_documents.length, (index) {
                var document = _documents[index];
                if (document is! AppDocumentFile) {
                  return Container();
                }
                return ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: 300, maxWidth: 300),
                    child: Card(
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        margin: const EdgeInsets.all(5),
                        child: InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                            onTap: () => _openDocument(document.path),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                            width: 300,
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(32)),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 10),
                                            child: Column(children: [
                                              Text(document.name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline6),
                                            ])),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: _buildRichText(document),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildPopupMenu(document)
                                ]))));
              }))));

  Widget _buildPopupMenu(AppDocumentFile file) => PopupMenuButton(
        itemBuilder: (context) => [
          PopupMenuItem(
            child: ListTile(
              leading: const Icon(PhosphorIcons.folderOpenLight),
              title: Text(AppLocalizations.of(context)!.open),
              onTap: () {
                Navigator.of(context).pop();
                _openDocument(file.path);
              },
            ),
            padding: EdgeInsets.zero,
          ),
          PopupMenuItem(
            child: ListTile(
                leading: const Icon(PhosphorIcons.copyLight),
                title: Text(AppLocalizations.of(context)!.duplicate),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _fileSystem.importDocument(file.load());
                  loadDocuments();
                }),
            padding: EdgeInsets.zero,
          ),
          PopupMenuItem(
            child: ListTile(
                leading: const Icon(PhosphorIcons.textTLight),
                title: Text(AppLocalizations.of(context)!.rename),
                onTap: () {
                  Navigator.of(context).pop();
                  _renameDialog(file.path);
                }),
            padding: EdgeInsets.zero,
          ),
          PopupMenuItem(
            child: ListTile(
              leading: const Icon(PhosphorIcons.trashLight),
              title: Text(AppLocalizations.of(context)!.delete),
              onTap: () {
                Navigator.of(context).pop();
                _deleteDialog(file.path);
              },
            ),
            padding: EdgeInsets.zero,
          ),
        ],
      );

  RichText _buildRichText(AppDocumentFile file) => RichText(
        text: TextSpan(
            text: file.description,
            style: Theme.of(context).textTheme.caption,
            children: [
              const TextSpan(
                text: '\n',
              ),
              TextSpan(
                text: file.path,
              ),
              const TextSpan(
                text: '\n',
              ),
              if (file.updatedAt != null)
                TextSpan(
                  text:
                      AppLocalizations.of(context)!.updatedAt(file.updatedAt!),
                ),
              if (file.createdAt != null) ...[
                const TextSpan(
                  text: '\n',
                ),
                TextSpan(
                  text:
                      AppLocalizations.of(context)!.createdAt(file.createdAt!),
                ),
              ]
            ]),
      );
}
