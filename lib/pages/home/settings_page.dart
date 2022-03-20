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
          title: 'Backup and Restore',
          onTap: user.isPro ? () => {} : null,
        ),
        const SettingsTitle(title: 'About'),
        SettingsItem(
          title: 'About Lazy1922',
          onTap: () => {},
        ),
      ],
    );
  }
}
