import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lazy1922/models/place.dart';

class PlacesNotifier extends StateNotifier<List<Place>> {
  Box<Place> get box => Hive.box<Place>("places");

  PlacesNotifier() : super(Hive.box<Place>("places").values.toList());

  void add(Place place) {
    box.add(place);
    state = box.values.toList();
  }

  void remove(int index) {
    box.deleteAt(index);
    state = box.values.toList();
  }
}

final placesProvider = StateNotifierProvider<PlacesNotifier, List<Place>>((ref) => PlacesNotifier());
