import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazy1922/models/code.dart';
import 'package:lazy1922/models/record.dart';
import 'package:lazy1922/providers/places_provider.dart';
import 'package:lazy1922/providers/records_provider.dart';
import 'package:lazy1922/providers/user_provider.dart';
import 'package:lazy1922/utils.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends ConsumerWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MobileScanner(
      allowDuplicates: false,
      onDetect: (barcode, args) => _onNewScan(context, ref, barcode),
    );
  }

  void _onNewScan(BuildContext context, WidgetRef ref, Barcode barcode) async {
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

    sendMessage(message);

    final user = ref.read(userProvider);
    if (!user.isPro) {
      return;
    }

    try {
      final location = await getLocation();
      final records = ref.read(recordsProvider);
      final places = ref.read(placesProvider);
      final record = Record(
        code: Code.parse(message),
        message: message,
        latitude: location.latitude,
        longitude: location.longitude,
        time: DateTime.now(),
      );

      if (!records.contains(record) && !places.contains(record)) {
        final recordsNotifier = ref.read(recordsProvider.notifier);
        recordsNotifier.add(record);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }
}
