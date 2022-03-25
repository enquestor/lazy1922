import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazy1922/providers/user_provider.dart';
import 'package:lazy1922/widgets/settings_item.dart';
import 'package:lazy1922/widgets/settings_title.dart';
import 'package:vrouter/vrouter.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsTitle(title: 'user'.tr()),
        SettingsItem(
          title: 'lazy1922_premium'.tr(),
          onTap: () => context.vRouter.toNamed('premium'),
        ),
        SettingsTitle(title: 'premium_settings'.tr()),
        SettingsItem(
          title: 'recommendation_range'.tr(),
          value: 'meter'.plural(user.recommendationRange),
          onTap: user.isPro ? () => _onRecommendationRangeTap(context, ref) : null,
        ),
        SettingsTitle(title: 'about'.tr()),
        SettingsItem(
          title: 'privacy_policy'.tr(),
          onTap: () => showDialog(context: context, builder: (context) => const PrivacyDialog()),
        ),
        SettingsItem(
          title: 'about'.tr(),
          onTap: () => showDialog(context: context, builder: (context) => const AboutDialog()),
        ),
      ],
    );
  }

  void _onRecommendationRangeTap(BuildContext context, WidgetRef ref) async {
    final range = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('recommendation_range'.tr()),
        children: [
          SimpleDialogOption(
            child: Text('distance.close'.tr()),
            onPressed: () => Navigator.of(context).pop(50),
          ),
          SimpleDialogOption(
            child: Text('distance.normal'.tr()),
            onPressed: () => Navigator.of(context).pop(200),
          ),
          SimpleDialogOption(
            child: Text('distance.far'.tr()),
            onPressed: () => Navigator.of(context).pop(500),
          ),
        ],
      ),
    );

    if (range != null) {
      final userNotifier = ref.watch(userProvider.notifier);
      userNotifier.setRecommendationRange(range);
    }
  }
}

class PrivacyDialog extends StatelessWidget {
  const PrivacyDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('privacy_policy'.tr()),
      content: Text('privacy_policy_message'.tr()),
      actions: [
        TextButton(
          child: Text('ok'.tr()),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class AboutDialog extends StatelessWidget {
  const AboutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('about'.tr()),
      content: Text('about_message'.tr()),
      actions: [
        TextButton(
          child: Text('ok'.tr()),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
