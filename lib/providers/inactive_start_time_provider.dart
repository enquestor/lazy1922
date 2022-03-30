import 'package:flutter_riverpod/flutter_riverpod.dart';

final inactiveStartTimeProvider = StateProvider<DateTime>((ref) => DateTime.now());
