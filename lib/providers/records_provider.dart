import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lazy1922/consts.dart';
import 'package:lazy1922/models/record.dart';

class RecordsNotifier extends StateNotifier<List<Record>> {
  Box<List> get box => Hive.box<List>("records");

  RecordsNotifier() : super((Hive.box<List>("records").get('records') ?? []).cast<Record>()..sort((a, b) => a.time.compareTo(b.time)));
  RecordsNotifier.override(List<Record> records) : super(records);

  @override
  bool updateShouldNotify(List<Record> old, List<Record> current) => true;

  @override
  set state(List<Record> value) {
    super.state = value;
    box.put('records', value);
  }

  void add(Record record) {
    state = [...state, record];
  }

  void redeemLastLocation(double latitude, double longitude) {
    if (DateTime.now().difference(state.last.time).inSeconds < maxLocationRedeemTime) {
      state = [
        ...state.take(state.length - 1),
        state.last.copyWith(latitude: latitude, longitude: longitude),
      ];
    }
  }

  void removeRecord(Record record) {
    state = state..removeWhere((r) => r.time == record.time);
  }
}

final recordsProvider = StateNotifierProvider<RecordsNotifier, List<Record>>((ref) => RecordsNotifier());
