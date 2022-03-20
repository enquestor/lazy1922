import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lazy1922/models/record.dart';

class RecordsNotifier extends StateNotifier<List<Record>> {
  Box<Record> get box => Hive.box<Record>("records");

  RecordsNotifier() : super(Hive.box<Record>("records").values.toList()) {
    final box = Hive.box<Record>("records");
    box.listenable().addListener(() {
      state = box.values.toList();
    });
  }

  void add(Record record) {
    box.add(record);
    state = box.values.toList();
  }

  void deleteAt(int index) {
    box.deleteAt(index);
    state = box.values.toList();
  }
}

final recordsProvider = StateNotifierProvider<RecordsNotifier, List<Record>>((ref) => RecordsNotifier());
