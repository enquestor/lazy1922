import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lazy1922/models/place.dart';
import 'package:lazy1922/models/record.dart';
import 'package:lazy1922/pages/home/home_page.dart';
import 'package:lazy1922/pages/home/scan_page.dart';
import 'package:lazy1922/pages/home/settings_page.dart';
import 'package:lazy1922/providers/data_provider.dart';
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
    return Scaffold(
      appBar: _buildAppBar(ref),
      body: _buildBody(ref),
      bottomNavigationBar: _buildNavigationBar(ref),
      floatingActionButton: pageIndex == 0
          ? FloatingActionButton(
              onPressed: () => _onFabPressed(context, ref),
              child: const Icon(Icons.add),
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
    final data = ref.read(dataProvider);
    if (data.records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scan a QR code first, then press add to add it to favorites.'),
        ),
      );
    }

    final selectedRecordIndex = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Add to Favorites'),
        children: data.records
            .asMap()
            .entries
            .map(
              (entry) => RecordOption(
                record: entry.value,
                onTap: () => Navigator.of(context).pop(entry.key),
              ),
            )
            .toList(),
      ),
    );

    if (selectedRecordIndex == null) {
      return;
    }

    final controller = TextEditingController();
    final placeName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Place'),
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter a name for this place',
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () => Navigator.of(context).pop(controller.text),
          ),
        ],
      ),
    );

    if (placeName == null) {
      return;
    }

    final dataNotifier = ref.read(dataProvider.notifier);
    dataNotifier.addPlace(Place.fromRecord(data.records[selectedRecordIndex], placeName));
  }
}

class RecordOption extends StatelessWidget {
  final Record record;
  final void Function() onTap;
  const RecordOption({Key? key, required this.record, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(DateFormat('M/d - hh:mm a').format(record.time)),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(record.code.formatted),
      ),
      onTap: () => Navigator.of(context).pop(0),
    );
  }
}
