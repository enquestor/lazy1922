import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazy1922/consts.dart';
import 'package:lazy1922/providers/user_provider.dart';
import 'package:lazy1922/widgets/dialog_list_tile.dart';
import 'package:lazy1922/widgets/settings_item.dart';
import 'package:lazy1922/widgets/settings_title.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr())),
      body: _buildSettings(context, ref),
    );
  }

  Widget _buildSettings(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsTitle(title: 'user'.tr()),
          SettingsItem(
            title: 'lazy1922_premium'.tr(),
            onTap: () => context.push('/settings/premium'),
          ),
          SettingsItem(
            title: 'language'.tr(),
            onTap: () => _onLanguageTap(context),
          ),
          SettingsItem(
            title: 'auto_return'.tr(),
            value: user.autoReturn == autoReturnMaxTime ? 'never'.tr() : 'after_minute_idle'.plural(user.autoReturn),
            onTap: () => _onAutoReturnTap(context, ref),
          ),
          SettingsTitle(title: 'premium_settings'.tr()),
          SettingsItem(
            title: 'suggestion_range'.tr(),
            value: 'within_meter'.plural(user.suggestionRange),
            onTap: user.isPremium ? () => _onSuggestionRangeTap(context, ref) : null,
          ),
          SettingsTitle(title: 'about'.tr()),
          SettingsItem(
            title: 'privacy_policy'.tr(),
            onTap: () => launch(privacyPolicyLink),
          ),
          SettingsItem(
            title: 'about'.tr(),
            onTap: () => showDialog(context: context, builder: (context) => const AboutDialog()),
          ),
        ],
      ),
    );
  }

  void _onSuggestionRangeTap(BuildContext context, WidgetRef ref) async {
    final range = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          title: Text('suggestion_range'.tr()),
          children: suggestionRangeOptions
              .map(
                (suggestionRange) => DialogListTile(
                  title: Text('within_meter'.plural(suggestionRange)),
                  onTap: () => Navigator.of(context).pop(suggestionRange),
                ),
              )
              .toList()),
    );

    if (range != null) {
      final userNotifier = ref.watch(userProvider.notifier);
      userNotifier.setSuggestionRange(range);
    }
  }

  void _onLanguageTap(BuildContext context) async {
    final locale = await showDialog<Locale>(
      context: context,
      builder: (context) => SimpleDialog(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        title: Text('language'.tr()),
        children: context.supportedLocales
            .map(
              (locale) => DialogListTile(
                title: Text(locale.toString().tr()),
                onTap: () => Navigator.of(context).pop(locale),
              ),
            )
            .toList(),
      ),
    );

    if (locale != null) {
      context.setLocale(locale);
    }
  }

  void _onAutoReturnTap(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        title: Text('auto_return'.tr()),
        children: [
          ...autoReturnOptions.map((autoReturn) => DialogListTile(
                title: Text('after_minute_idle'.plural(autoReturn)),
                onTap: () => Navigator.of(context).pop(autoReturn),
              )),
          DialogListTile(
            title: Text('never'.tr()),
            onTap: () => Navigator.of(context).pop(autoReturnMaxTime),
          ),
        ],
      ),
    );
    if (result != null) {
      final userNotifier = ref.watch(userProvider.notifier);
      userNotifier.setAutoReturn(result);
    }
  }
}

class AboutDialog extends ConsumerStatefulWidget {
  const AboutDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<AboutDialog> createState() => _AboutDialogState();
}

class _AboutDialogState extends ConsumerState<AboutDialog> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    final userNotifer = ref.watch(userProvider.notifier);
    return AlertDialog(
      title: Text('about'.tr()),
      content: Text('about_message'.tr()),
      actions: [
        Opacity(
          opacity: 0,
          child: TextButton(
            child: const Text('gogo'),
            onPressed: () {
              setState(() => _count++);
              if (_count == 5) {
                userNotifer.fakeUpgrade();
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        TextButton(
          child: Text('ok'.tr()),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
