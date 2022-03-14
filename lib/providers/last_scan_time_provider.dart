import 'package:flutter_riverpod/flutter_riverpod.dart';

final lastScanTimeProvider = StateProvider<DateTime>((ref) => DateTime.now());
