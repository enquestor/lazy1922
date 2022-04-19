import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazy1922/models/selected_page.dart';
import 'package:lazy1922/pages/home/home_page.dart';
import 'package:lazy1922/pages/home/messages_page.dart';
import 'package:lazy1922/pages/home/scan_page.dart';
import 'package:lazy1922/pages/home/settings_page.dart';
import 'package:lazy1922/providers/user_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  final SelectedPage selectedPage;
  const HomeScreen({Key? key, required this.selectedPage}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: _buildBody(ref),
      bottomNavigationBar: _buildNavigationBar(context, ref),
    );
  }

  Widget _buildBody(WidgetRef ref) {
    switch (selectedPage) {
      case SelectedPage.home:
        return const HomePage();
      case SelectedPage.scan:
        return const ScanPage();
      case SelectedPage.messages:
        return const MessagesPage();
      case SelectedPage.settings:
        return const SettingsPage();
    }
  }

  Widget _buildNavigationBar(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final selectedPageIndex = SelectedPage.values.indexOf(selectedPage);

    return NavigationBar(
      selectedIndex: user.isPremium ? selectedPageIndex : selectedPageIndex - 1,
      onDestinationSelected: (value) => context.go('/${EnumToString.convertToString(SelectedPage.values[user.isPremium ? value : value + 1])}'),
      destinations: [
        if (user.isPremium)
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            label: 'home'.tr(),
          ),
        NavigationDestination(
          icon: const Icon(Icons.camera_alt_outlined),
          label: 'scan'.tr(),
        ),
        NavigationDestination(
          icon: const Icon(Icons.message_outlined),
          label: 'messages'.tr(),
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          label: 'settings'.tr(),
        ),
      ],
    );
  }
}
