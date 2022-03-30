import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazy1922/models/selected_page.dart';
import 'package:lazy1922/pages/home/home_page.dart';
import 'package:lazy1922/pages/home/messages_page.dart';
import 'package:lazy1922/pages/home/scan_page.dart';
import 'package:lazy1922/pages/home/settings_page.dart';
import 'package:lazy1922/providers/is_place_mode_provider.dart';
import 'package:lazy1922/providers/selected_page_provider.dart';
import 'package:lazy1922/providers/user_provider.dart';
import 'package:easy_localization/easy_localization.dart';

final _selectedIndexProvider = Provider<int>((ref) {
  final user = ref.watch(userProvider);
  final currentPage = ref.watch(selectedPageProvider);
  if (user.isPremium) {
    return currentPage.index;
  } else {
    return currentPage.index - 1;
  }
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: _buildBody(ref),
      bottomNavigationBar: _buildNavigationBar(ref),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    final selectedPage = ref.watch(selectedPageProvider);
    final isPlaceMode = ref.watch(isPlaceModeProvider);
    final isPlaceModeNotifier = ref.watch(isPlaceModeProvider.notifier);
    late final String appBarTitle;

    switch (selectedPage) {
      case SelectedPage.home:
        appBarTitle = 'home'.tr();
        break;
      case SelectedPage.scan:
        appBarTitle = 'scan'.tr();
        break;
      case SelectedPage.messages:
        appBarTitle = '1922';
        break;
      case SelectedPage.settings:
        appBarTitle = 'settings'.tr();
        break;
    }

    return AppBar(
      title: Text(appBarTitle),
      actions: selectedPage == SelectedPage.messages
          ? [
              IconButton(
                icon: Icon(
                  Icons.location_on_outlined,
                  color: isPlaceMode ? Theme.of(context).colorScheme.primary : null,
                ),
                splashRadius: 20,
                onPressed: () => isPlaceModeNotifier.state = !isPlaceModeNotifier.state,
              )
            ]
          : null,
    );
  }

  Widget _buildBody(WidgetRef ref) {
    final selectedPage = ref.watch(selectedPageProvider);
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

  Widget _buildNavigationBar(WidgetRef ref) {
    var destinations = [
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
    ];
    final user = ref.watch(userProvider);

    if (user.isPremium) {
      destinations = [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          label: 'home'.tr(),
        ),
        ...destinations,
      ];
    }

    return NavigationBar(
      selectedIndex: ref.watch(_selectedIndexProvider),
      onDestinationSelected: (value) {
        final user = ref.watch(userProvider);
        final selectedPageNotifier = ref.read(selectedPageProvider.notifier);
        if (user.isPremium) {
          selectedPageNotifier.state = SelectedPage.values[value];
        } else {
          selectedPageNotifier.state = SelectedPage.values[value + 1];
        }
      },
      destinations: destinations,
    );
  }
}
