import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazy1922/providers/user_provider.dart';
import 'package:lazy1922/widgets/settings_item.dart';
import 'package:lazy1922/widgets/settings_title.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final userNotifier = ref.watch(userProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsTitle(title: 'User'),
        SettingsItem(
          title: 'Upgrade to Pro',
          onTap: () => userNotifier.upgradeToPro(),
        ),
        const SettingsTitle(title: 'Pro Features'),
        SettingsItem(
          title: 'Recommendation Range',
          onTap: user.isPro ? () => {} : null,
        ),
        const SettingsTitle(title: 'About'),
        SettingsItem(
          title: 'Privacy Policy',
          onTap: () => showDialog(context: context, builder: (context) => const PrivacyDialog()),
        ),
        SettingsItem(
          title: 'About',
          onTap: () => showDialog(context: context, builder: (context) => const AboutDialog()),
        ),
      ],
    );
  }
}

class PrivacyDialog extends StatelessWidget {
  const PrivacyDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Privacy Policy'),
      content: const Text('Lazy1922 only uses your GPS and stores all data locally. No data is sent to the server.'),
      actions: [
        TextButton(
          child: const Text('OK'),
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
      title: const Text('About'),
      content: const Text('Lazy1922 is a tool to help you scan 1922 SMS messages.'),
      actions: [
        TextButton(
          child: const Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
