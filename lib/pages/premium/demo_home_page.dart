import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazy1922/models/code.dart';
import 'package:lazy1922/models/place.dart';
import 'package:lazy1922/pages/home/home_page.dart';
import 'package:lazy1922/providers/places_provider.dart';
import 'package:tuple/tuple.dart';

final demoPlaces = [
  Place(
    code: Code('111213141516171'),
    message: '',
    name: '賣當老',
    time: DateTime.now(),
    latitude: 0,
    longitude: 0,
  ),
  Place(
    code: Code('101112131415161'),
    message: '',
    name: '肯得雞',
    time: DateTime.now(),
    latitude: 0,
    longitude: 0,
  ),
  Place(
    code: Code('164381621251684'),
    message: '',
    name: '磨獅汗飽',
    time: DateTime.now(),
    latitude: 0,
    longitude: 0,
  ),
];
final demoPlacesProvider = StateNotifierProvider<PlacesNotifier, List<Place>>((ref) => PlacesNotifier.override(demoPlaces));
final demoSuggestedPlaceProvider = FutureProvider.autoDispose<Tuple2<Place, double>>((ref) => Future.value(Tuple2(demoPlaces[2], 0.4)));

class DemoHomePage extends StatelessWidget {
  const DemoHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ProviderScope(
        overrides: [
          placesProvider.overrideWithProvider(demoPlacesProvider),
          suggestedPlaceProvider.overrideWithProvider(demoSuggestedPlaceProvider),
        ],
        child: const HomePage(),
      ),
    );
  }
}
