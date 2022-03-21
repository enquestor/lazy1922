import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lazy1922/models/record.dart';

class RecordsNotifier extends StateNotifier<List<Record>> {
  Box<List> get box => Hive.box<List>("records");

  RecordsNotifier() : super((Hive.box<List>("records").get('records') ?? []).cast<Record>());

  @override
  bool updateShouldNotify(List<Record> old, List<Record> current) => true;

  @override
  set state(List<Record> value) {
    super.state = value;
    box.put('records', value);
  }

  void add(Record record) {
    state = state..add(record);
  }
}

final recordsProvider = StateNotifierProvider<RecordsNotifier, List<Record>>((ref) => RecordsNotifier());
