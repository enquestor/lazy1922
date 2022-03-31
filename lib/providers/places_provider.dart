import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lazy1922/models/code.dart';
import 'package:lazy1922/models/place.dart';

class PlacesNotifier extends StateNotifier<List<Place>> {
  Box<List> get box => Hive.box<List>("places");

  PlacesNotifier() : super((Hive.box<List>("places").get('places') ?? []).cast<Place>());
  PlacesNotifier.override(List<Place> places) : super(places);

  @override
  bool updateShouldNotify(List<Place> old, List<Place> current) => true;

  @override
  set state(List<Place> value) {
    super.state = value;
    box.put('places', value);
  }

  void add(Place place) {
    state = state..add(place);
  }

  void edit(Place place) {
    final index = state.indexOf(place);
    state = state
      ..remove(place)
      ..insert(index, place);
  }

  void remove(Place place) {
    state = state..remove(place);
  }

  void move(int oldIndex, int newIndex) {
    final place = state[oldIndex];
    state = state
      ..removeAt(oldIndex)
      ..insert(newIndex, place);
  }
}

final placesProvider = StateNotifierProvider<PlacesNotifier, List<Place>>((ref) => PlacesNotifier());
final placesMapProvider = Provider<Map<Code, Place>>((ref) {
  final places = ref.watch(placesProvider);
  final placesMap = <Code, Place>{};
  for (final place in places) {
    placesMap[place.code] = place;
  }
  return placesMap;
});
