import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazy1922/models/code.dart';
import 'package:lazy1922/models/record.dart';
import 'package:lazy1922/models/selected_page.dart';
import 'package:lazy1922/providers/records_provider.dart';
import 'package:lazy1922/providers/selected_page_provider.dart';
import 'package:lazy1922/providers/user_provider.dart';
import 'package:lazy1922/utils.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends ConsumerWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MobileScanner(
      allowDuplicates: false,
      onDetect: (barcode, args) => _onNewScan(ref, barcode),
    );
  }

  void _onNewScan(WidgetRef ref, Barcode barcode) async {
    // ignore if not sms code
    if (barcode.sms == null) {
      return;
    }
    final sms = barcode.sms!;

    // ignore if not to 1922 or no message
    if (sms.phoneNumber != '1922' || sms.message == null) {
      return;
    }
    final message = sms.message!;

    await sendMessage(message);

    // add record
    final record = Record(
      code: Code.parse(message),
      message: message,
      time: DateTime.now(),
    );
    final recordsNotifier = ref.read(recordsProvider.notifier);
    recordsNotifier.add(record);

    // change page to messages
    final selectedPageNotifier = ref.read(selectedPageProvider.notifier);
    selectedPageNotifier.state = SelectedPage.messages;

    final user = ref.read(userProvider);
    if (!user.isPremium) {
      return;
    }

    try {
      // defer location task to instantly show record in UI
      final location = await getLocation();
      recordsNotifier.redeemLastLocation(location.latitude, location.longitude);
    } catch (error) {
      // ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      //   SnackBar(content: Text(error.toString())),
      // );
    }
  }
}
