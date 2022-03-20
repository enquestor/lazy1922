import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lazy1922/models/place.dart';
import 'package:lazy1922/models/record.dart';
import 'package:lazy1922/pages/home/home_page.dart';
import 'package:lazy1922/pages/home/scan_page.dart';
import 'package:lazy1922/pages/home/settings_page.dart';
import 'package:lazy1922/providers/data_provider.dart';
import 'package:lazy1922/providers/is_edit_mode_provider.dart';
import 'package:lazy1922/providers/user_provider.dart';

final _rawPageIndexProvider = StateProvider.autoDispose<int>((ref) => 0);
final _pageIndexProvider = Provider.autoDispose<int>((ref) {
  final user = ref.watch(userProvider);
  final rawPageIndex = ref.watch(_rawPageIndexProvider);

  if (!user.isPro) {
    return rawPageIndex + 1;
  } else {
    return rawPageIndex;
  }
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageIndex = ref.watch(_pageIndexProvider);
    final isEditMode = ref.watch(isEditModeProvider);
    return Scaffold(
      appBar: _buildAppBar(ref),
      body: _buildBody(ref),
      bottomNavigationBar: _buildNavigationBar(ref),
      floatingActionButton: pageIndex == 0
          ? FloatingActionButton(
              onPressed: () => _onFabPressed(context, ref),
              child: isEditMode ? const Icon(Icons.close) : const Icon(Icons.edit),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(WidgetRef ref) {
    final pageIndex = ref.watch(_pageIndexProvider);
    late final String appBarTitle;

    switch (pageIndex) {
      case 0:
        appBarTitle = 'Home';
        break;
      case 1:
        appBarTitle = 'Scan';
        break;
      case 2:
        appBarTitle = 'Settings';
        break;
    }

    return AppBar(title: Text(appBarTitle));
  }

  Widget _buildBody(WidgetRef ref) {
    int pageIndex = ref.watch(_pageIndexProvider);

    switch (pageIndex) {
      case 0:
        return const HomePage();
      case 1:
        return const ScanPage();
      case 2:
        return const SettingsPage();
      default:
        return const HomePage();
    }
  }

  Widget _buildNavigationBar(WidgetRef ref) {
    var destinations = [
      const NavigationDestination(
        icon: Icon(Icons.camera_alt_outlined),
        label: 'Scan',
      ),
      const NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        label: 'Settings',
      ),
    ];
    final user = ref.watch(userProvider);

    if (user.isPro) {
      destinations.insert(
        0,
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
      );
    }

    return NavigationBar(
      selectedIndex: ref.watch(_rawPageIndexProvider),
      onDestinationSelected: (value) => ref.read(_rawPageIndexProvider.notifier).state = value,
      destinations: destinations,
    );
  }

  void _onFabPressed(BuildContext context, WidgetRef ref) async {
    final isEditMode = ref.watch(isEditModeProvider);
    final isEditModeNotifier = ref.read(isEditModeProvider.notifier);
    if (isEditMode) {
      isEditModeNotifier.state = false;
    } else {
      isEditModeNotifier.state = true;
    }
  }
}
