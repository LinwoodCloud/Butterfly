import 'dart:convert';

import 'package:butterfly/api/open.dart';
import 'package:butterfly/api/save.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../widgets/window.dart';

@immutable
class Meta {
  final String stableVersion, nightlyVersion, developVersion, mainVersion;

  const Meta({
    required this.stableVersion,
    required this.nightlyVersion,
    required this.developVersion,
    required this.mainVersion,
  });
  Meta.fromJson(Map<String, dynamic> json)
      : stableVersion = json['version']?['stable'] ?? '?',
        nightlyVersion = json['version']?['nightly'] ?? '?',
        developVersion = json['version']?['develop'] ?? '?',
        mainVersion = json['version']?['main'] ?? '?';
}

class GeneralSettingsPage extends StatelessWidget {
  final bool inView;
  const GeneralSettingsPage({super.key, this.inView = false});

  Future<Meta> _fetchMeta() async {
    final response =
        await http.get(Uri.parse('https://butterfly.linwood.dev/meta.json'));
    return Meta.fromJson({...json.decode(response.body)});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: inView ? Colors.transparent : null,
      appBar: WindowTitleBar(
        title: Text(AppLocalizations.of(context).general),
        backgroundColor: inView ? Colors.transparent : null,
        inView: inView,
      ),
      body: FutureBuilder(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final currentVersion = snapshot.data?.version ?? '?';
          return ListView(children: [
            Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppLocalizations.of(context).update,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title:
                            Text(AppLocalizations.of(context).currentVersion),
                        subtitle: Text(currentVersion),
                        onTap: () => saveToClipboard(context, currentVersion),
                      ),
                      if (!kIsWeb)
                        FutureBuilder<Meta>(
                            future: _fetchMeta(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              final meta = snapshot.data!;
                              final stableVersion = meta.stableVersion;
                              final nightlyVersion = meta.nightlyVersion;
                              final developVersion = meta.developVersion;
                              final mainVersion = meta.mainVersion;
                              final isStable = currentVersion == stableVersion;
                              final isNightly =
                                  currentVersion == nightlyVersion;
                              final isDevelop =
                                  currentVersion == developVersion;
                              final isMain = currentVersion == mainVersion;
                              final isError = meta.nightlyVersion == '?' ||
                                  meta.stableVersion == '?';
                              final isUpdateAvailable = !isError &&
                                  !isStable &&
                                  !isNightly &&
                                  !isDevelop &&
                                  !isMain;
                              return Column(children: [
                                ListTile(
                                  title:
                                      Text(AppLocalizations.of(context).stable),
                                  subtitle: Text(stableVersion),
                                  onTap: () =>
                                      saveToClipboard(context, stableVersion),
                                ),
                                ListTile(
                                  title: Text(
                                      AppLocalizations.of(context).nightly),
                                  subtitle: Text(nightlyVersion),
                                  onTap: () =>
                                      saveToClipboard(context, nightlyVersion),
                                ),
                                const Divider(),
                                if (isStable) ...[
                                  ListTile(
                                    title: Text(AppLocalizations.of(context)
                                        .usingLatestStable),
                                  ),
                                ] else if (isNightly ||
                                    isDevelop ||
                                    isMain) ...[
                                  ListTile(
                                    title: Text(AppLocalizations.of(context)
                                        .usingLatestNightly),
                                  )
                                ] else if (isError) ...[
                                  ListTile(
                                    title: Text(
                                        AppLocalizations.of(context).error),
                                  ),
                                ] else if (isUpdateAvailable)
                                  ListTile(
                                    title: Text(AppLocalizations.of(context)
                                        .updateAvailable),
                                    subtitle: Text(
                                        AppLocalizations.of(context).updateNow),
                                    leading: const PhosphorIcon(
                                        PhosphorIconsLight.arrowRight),
                                    onTap: () async {
                                      await launchUrl(
                                          Uri.parse(
                                              'https://butterfly.linwood.dev/downloads'),
                                          mode: LaunchMode.externalApplication);
                                    },
                                  ),
                              ]);
                            }),
                    ]),
              ),
            ),
            Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                          leading:
                              const PhosphorIcon(PhosphorIconsLight.article),
                          title:
                              Text(AppLocalizations.of(context).documentation),
                          onTap: () => launchUrl(
                              Uri.https('butterfly.linwood.dev', ''),
                              mode: LaunchMode.externalApplication)),
                      ListTile(
                          leading: const PhosphorIcon(PhosphorIconsLight.flag),
                          title:
                              Text(AppLocalizations.of(context).releaseNotes),
                          onTap: () => openReleaseNotes()),
                      ListTile(
                          leading: const PhosphorIcon(PhosphorIconsLight.users),
                          title: const Text('Matrix'),
                          onTap: () => launchUrl(
                              Uri.https('go.linwood.dev', 'matrix'),
                              mode: LaunchMode.externalApplication)),
                      ListTile(
                          leading: const PhosphorIcon(PhosphorIconsLight.users),
                          title: const Text('Discord'),
                          onTap: () => launchUrl(
                              Uri.https('go.linwood.dev', 'discord'),
                              mode: LaunchMode.externalApplication)),
                      ListTile(
                          leading:
                              const PhosphorIcon(PhosphorIconsLight.translate),
                          title: const Text('Crowdin'),
                          onTap: () => launchUrl(
                              Uri.https('go.linwood.dev', 'butterfly/crowdin'),
                              mode: LaunchMode.externalApplication)),
                      ListTile(
                          leading: const PhosphorIcon(PhosphorIconsLight.code),
                          title: Text(AppLocalizations.of(context).source),
                          onTap: () => launchUrl(
                              Uri.https('go.linwood.dev', 'butterfly/source'),
                              mode: LaunchMode.externalApplication)),
                      ListTile(
                          leading: const PhosphorIcon(
                              PhosphorIconsLight.arrowCounterClockwise),
                          title: Text(AppLocalizations.of(context).changelog),
                          onTap: () => launchUrl(
                              Uri.https('butterfly.linwood.dev', 'changelog'),
                              mode: LaunchMode.externalApplication)),
                    ]),
              ),
            ),
            Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                          leading: const PhosphorIcon(PhosphorIconsLight.stack),
                          title: Text(AppLocalizations.of(context).license),
                          onTap: () => launchUrl(
                              Uri.https('go.linwood.dev', 'butterfly/license'),
                              mode: LaunchMode.externalApplication)),
                      ListTile(
                          leading: const PhosphorIcon(
                              PhosphorIconsLight.identificationCard),
                          title: Text(AppLocalizations.of(context).imprint),
                          onTap: () => launchUrl(
                              Uri.https('go.linwood.dev', 'impress'),
                              mode: LaunchMode.externalApplication)),
                      ListTile(
                          leading:
                              const PhosphorIcon(PhosphorIconsLight.shield),
                          title:
                              Text(AppLocalizations.of(context).privacypolicy),
                          onTap: () => launchUrl(
                              Uri.https(
                                  'butterfly.linwood.dev', 'privacypolicy'),
                              mode: LaunchMode.externalApplication)),
                      ListTile(
                        title: Text(
                            AppLocalizations.of(context).thirdPartyLicenses),
                        leading: const PhosphorIcon(PhosphorIconsLight.file),
                        onTap: () => showLicensePage(context: context),
                      )
                    ]),
              ),
            ),
          ]);
        },
      ),
    );
  }
}
