import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lazy1922/models/place.dart';

class PlacesNotifier extends StateNotifier<List<Place>> {
  Box<List> get box => Hive.box<List>("places");

  PlacesNotifier() : super((Hive.box<List>("places").get('places') ?? []).cast<Place>());

  @override
  bool updateShouldNotify(List<Place> old, List<Place> current) => true;

  @override
  set state(List<Place> value) {
    super.state = value;
    box.put('places', value);
  }

  Future<void> add(Place place) async {
    state = state..add(place);
  }

  Future<void> removeAt(int index) async {
    state = state..removeAt(index);
  }

  Future<void> move(int oldIndex, int newIndex) async {
    final place = state[oldIndex];
    state = state
      ..removeAt(oldIndex)
      ..insert(newIndex, place);
  }
}

final placesProvider = StateNotifierProvider<PlacesNotifier, List<Place>>((ref) => PlacesNotifier());
