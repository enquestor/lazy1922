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

class HomeScreen extends ConsumerStatefulWidget {
  final SelectedPage selectedPage;
  const HomeScreen({Key? key, required this.selectedPage}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      final user = ref.read(userProvider);
      if (user.isTrialEnded && !user.isTrialEndMessageShown) {
        final userNotifier = ref.read(userProvider.notifier);
        userNotifier.setTrialEndedMessageShown();

        final goPurchase = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('trial_ended'.tr()),
            content: Text('trial_ended_message'.tr()),
            actions: [
              TextButton(
                child: Text('no'.tr()),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('sure'.tr()),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );

        if (goPurchase != null && goPurchase) {
          context.go('/settings/premium');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  Widget _buildBody() {
    switch (widget.selectedPage) {
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

  Widget _buildNavigationBar() {
    final user = ref.watch(userProvider);
    final selectedPageIndex = SelectedPage.values.indexOf(widget.selectedPage);

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
