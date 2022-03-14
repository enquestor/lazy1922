import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazy1922/consts.dart';
import 'package:lazy1922/models/data.dart';
import 'package:lazy1922/models/place.dart';
import 'package:lazy1922/models/record.dart';
import 'package:path_provider/path_provider.dart';

class DataNotifier extends StateNotifier<Data> {
  DataNotifier() : super(Data.template()) {
    initialize();
  }

  Future<File> _getDataFile() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    File file = File('$appDocPath/data.json');
    return file;
  }

  Future<void> initialize() async {
    final file = await _getDataFile();
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      Map<String, dynamic> json = jsonDecode(jsonString);
      state = Data.fromJson(json);
    }
  }

  Future<void> save() async {
    final file = await _getDataFile();
    final json = state.toJson();
    file.writeAsString(jsonEncode(json));
  }

  void addRecord(Record record) {
    state = state.copyWith(
      records: ([record] + state.records).take(maxRecordCount).toList(),
    );
  }

  void addPlace(Place place) {
    state = state.copyWith(
      places: [place] + state.places,
    );
  }
}

final dataProvider = StateNotifierProvider<DataNotifier, Data>((ref) => DataNotifier());
