import 'package:butterfly/api/open.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_leap/material_leap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../cubits/settings.dart';

class KeyboardBehaviorSettings extends StatelessWidget {
  const KeyboardBehaviorSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: WindowTitleBar<SettingsCubit, ButterflySettings>(
          title: Text(AppLocalizations.of(context).keyboard),
        ),
        body: Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: LeapBreakpoints.compact),
            child: BlocBuilder<SettingsCubit, ButterflySettings>(
              builder: (context, state) => ListView(
                children: [
                  ListTile(
                      title: Text(AppLocalizations.of(context).shortcuts),
                      leading: const PhosphorIcon(PhosphorIconsLight.keyboard),
                      onTap: () => openHelp(['shortcuts'], 'keyboard')),
                ],
              ),
            ),
          ),
        ));
  }
}
