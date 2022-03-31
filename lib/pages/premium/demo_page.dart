import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazy1922/models/code.dart';
import 'package:lazy1922/models/place.dart';
import 'package:lazy1922/models/record.dart';
import 'package:lazy1922/pages/home/home_page.dart';
import 'package:lazy1922/providers/is_place_mode_provider.dart';
import 'package:lazy1922/providers/pending_message_provider.dart';
import 'package:lazy1922/providers/places_provider.dart';
import 'package:lazy1922/providers/records_provider.dart';
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
final demoRecords = [
  Record.fromPlace(demoPlaces[0]).copyWith(time: DateTime(2022, 3, 30, 6, 30)),
  Record.fromPlace(demoPlaces[1]).copyWith(time: DateTime(2022, 3, 30, 12, 0)),
  Record.fromPlace(demoPlaces[2]).copyWith(time: DateTime(2022, 3, 30, 17, 55)),
  Record(
    code: Code('172164238456921'),
    message: '場所代碼：1721 6423 8456 921\n本簡訊是簡訊實聯制發送，限防疫目的使用。',
    time: DateTime.now(),
    latitude: 0,
    longitude: 0,
  ),
  Record.fromPlace(demoPlaces[1]).copyWith(time: DateTime(2022, 3, 31, 12, 2)),
  Record.fromPlace(demoPlaces[0]).copyWith(time: DateTime(2022, 3, 31, 22, 20)),
];

class DemoPage extends StatelessWidget {
  final Widget child;
  const DemoPage({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ProviderScope(
        overrides: [
          placesProvider.overrideWithValue(PlacesNotifier.override(demoPlaces)),
          suggestedPlaceProvider.overrideWithValue(AsyncValue.data(Tuple2(demoPlaces[0], 0.0))),
          recordsProvider.overrideWithValue(RecordsNotifier.override(demoRecords)),
          pendingMessageProvider.overrideWithValue(StateController(null)),
          isPlaceModeProvider.overrideWithValue(StateController(true)),
        ],
        child: child,
      ),
    );
  }
}
