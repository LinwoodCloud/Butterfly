import 'dart:ui' as ui;

import 'package:butterfly/api/open.dart';
import 'package:butterfly/bloc/document_bloc.dart';
import 'package:butterfly/dialogs/texture.dart';
import 'package:butterfly/visualizer/preset.dart';
import 'package:butterfly_api/butterfly_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_leap/material_leap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

part 'general.dart';
part 'properties/texture.dart';
part 'properties/image.dart';
part 'properties/svg.dart';

class BackgroundDialog extends StatelessWidget {
  const BackgroundDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentBloc, DocumentState>(
        buildWhen: (previous, current) =>
            previous.page?.backgrounds != current.page?.backgrounds,
        builder: (context, state) {
          if (state is! DocumentLoadSuccess) return Container();
          var background = state.page.backgrounds.firstOrNull;

          return ResponsiveAlertDialog(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
            title: Text(AppLocalizations.of(context).background),
            leading: const PhosphorIcon(PhosphorIconsLight.image),
            headerActions: [
              IconButton(
                tooltip: AppLocalizations.of(context).help,
                icon: const PhosphorIcon(PhosphorIconsLight.sealQuestion),
                onPressed: () => openHelp(['background']),
              ),
            ],
            content: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabAlignment: TabAlignment.fill,
                    tabs: [
                      (
                        PhosphorIconsLight.gridFour,
                        AppLocalizations.of(context).general,
                      ),
                      (
                        PhosphorIconsLight.gear,
                        AppLocalizations.of(context).properties,
                      ),
                    ]
                        .map((e) => HorizontalTab(
                              icon: PhosphorIcon(e.$1),
                              label: Text(e.$2),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: StatefulBuilder(builder: (context, setState) {
                      return TabBarView(
                        children: [
                          _GeneralBackgroundPropertiesView(
                              value: background,
                              onChanged: (value) =>
                                  setState(() => background = value)),
                          if (background != null) ...[
                            switch (background!) {
                              TextureBackground e =>
                                _TextureBackgroundPropertiesView(
                                    value: e,
                                    onChanged: (value) =>
                                        setState(() => background = value)),
                              ImageBackground e =>
                                _ImageBackgroundPropertiesView(
                                    value: e,
                                    onChanged: (value) =>
                                        setState(() => background = value)),
                              SvgBackground e => _SvgBackgroundPropertiesView(
                                  value: e,
                                  onChanged: (value) =>
                                      setState(() => background = value)),
                            },
                          ] else
                            const SizedBox(),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: Text(AppLocalizations.of(context).save),
                onPressed: () {
                  context.read<DocumentBloc>().add(DocumentBackgroundsChanged(
                      [if (background != null) background!]));
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
