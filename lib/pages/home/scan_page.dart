import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazy1922/models/code.dart';
import 'package:lazy1922/models/record.dart';
import 'package:lazy1922/models/selected_page.dart';
import 'package:lazy1922/providers/pending_message_provider.dart';
import 'package:lazy1922/providers/selected_page_provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends ConsumerWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('scan'.tr())),
      body: MobileScanner(
        allowDuplicates: false,
        onDetect: (barcode, args) => _onNewScan(ref, barcode),
      ),
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

    // set pending message
    final pendingMessageNotifier = ref.read(pendingMessageProvider.notifier);
    pendingMessageNotifier.state = Record(
      code: Code.parse(message),
      message: message,
      time: DateTime.now(),
    );

    // change page to messages
    final selectedPageNotifier = ref.read(selectedPageProvider.notifier);
    selectedPageNotifier.state = SelectedPage.messages;
  }
}
