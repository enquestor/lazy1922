import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazy1922/models/code.dart';
import 'package:lazy1922/models/record.dart';
import 'package:lazy1922/providers/last_scan_time_provider.dart';
import 'package:lazy1922/providers/places_provider.dart';
import 'package:lazy1922/providers/records_provider.dart';
import 'package:lazy1922/providers/user_provider.dart';
import 'package:lazy1922/utils.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanPage extends ConsumerWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return QRView(
      key: GlobalKey(debugLabel: 'QR'),
      onQRViewCreated: (controller) => _onQRViewCreated(context, ref, controller),
      overlay: QrScannerOverlayShape(
        borderColor: Theme.of(context).colorScheme.primary,
        borderRadius: 24,
        borderLength: 40,
        borderWidth: 12,
        cutOutSize: 300,
      ),
    );
  }

  void _onQRViewCreated(BuildContext context, WidgetRef ref, QRViewController controller) {
    controller.scannedDataStream.listen((scanData) => _onNewScan(context, ref, scanData));
  }

  void _onNewScan(BuildContext context, WidgetRef ref, Barcode scanData) async {
    final lastScanTime = ref.read(lastScanTimeProvider);
    if (DateTime.now().difference(lastScanTime).inSeconds < 1) {
      return;
    } else {
      ref.read(lastScanTimeProvider.notifier).state = DateTime.now();
    }

    var message = scanData.code;
    if (message == null || !message.toLowerCase().startsWith('smsto:1922:')) {
      return;
    }

    message = message.substring(11);
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
