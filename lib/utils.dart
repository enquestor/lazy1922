import 'dart:developer';

import 'package:background_sms/background_sms.dart';
import 'package:flutter_sms/flutter_sms.dart' as flutter_sms;
import 'package:geolocator/geolocator.dart';
import 'package:lazy1922/models/lazy_location_error.dart';
import 'package:permission_handler/permission_handler.dart';

Future<Position> getLocation() async {
  // check if service is enabled
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw LazyLocationError.serviceNotEnabled;
  }

  // check if perission is granted
  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    throw LazyLocationError.permissionDenied;
  } else if (permission == LocationPermission.deniedForever) {
    throw LazyLocationError.permissionDeniedForever;
  }

  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}

Future<void> sendSMS(String message) async {
  try {
    await flutter_sms.sendSMS(message: message, recipients: ['1922']);
  } catch (error) {
    log(error.toString(), name: 'SMS');
  }
}

Future<void> sendBackgroundSMS(String message) async {
  await Permission.sms.request();

  await BackgroundSms.sendMessage(
    phoneNumber: '1922',
    message: message,
  );
}

DateTime date(DateTime time) {
  return DateTime(time.year, time.month, time.day);
}
