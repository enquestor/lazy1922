import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lazy1922/models/lazy_error.dart';
import 'package:lazy1922/models/place.dart';
import 'package:lazy1922/models/record.dart';
import 'package:lazy1922/providers/is_edit_mode_provider.dart';
import 'package:lazy1922/providers/places_provider.dart';
import 'package:lazy1922/providers/records_provider.dart';
import 'package:lazy1922/utils.dart';
import 'package:lazy1922/widgets/ccpi.dart';
import 'package:tuple/tuple.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditMode = ref.watch(isEditModeProvider);
    final places = ref.watch(placesProvider);
    final children = List<Widget>.from(places.map((place) => PlaceCard(key: Key(place.code.value), place: place)).toList());
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeTitle(title: 'Recommendation'),
            const RecommendationCard(),
            const SizedBox(height: 32),
            const HomeTitle(title: 'Favorites'),
            ReorderableBuilder(
              lockedIndices: [children.length],
              enableDraggable: isEditMode,
              enableLongPress: true,
              dragChildBoxDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              children: [
                ...children,
                const AddCard(key: Key('addCard')),
              ],
              onReorder: (orderUpdateEntities) {
                // TODO: update underlying list
              },
              builder: (children, scrollController) => GridView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                controller: scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTitle extends StatelessWidget {
  final String title;
  const HomeTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headline5!.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

final _recommendedPlaceProvider = FutureProvider.autoDispose<Tuple2<Place, double>>((ref) async {
  final places = ref.watch(placesProvider);
  if (places.isEmpty) {
    throw LazyError.noSavedPlaces;
  }

  final location = await getLocation();
  places.sort((a, b) {
    final distanceA = Geolocator.distanceBetween(a.latitude, a.longitude, location.latitude, location.longitude);
    final distanceB = Geolocator.distanceBetween(b.latitude, b.longitude, location.latitude, location.longitude);
    return distanceA.compareTo(distanceB);
  });

  final recommendedPlace = places.first;
  final distance = Geolocator.distanceBetween(recommendedPlace.latitude, recommendedPlace.longitude, location.latitude, location.longitude);
  return Tuple2(recommendedPlace, distance);
});

class RecommendationCard extends ConsumerWidget {
  const RecommendationCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendedPlace = ref.watch(_recommendedPlaceProvider);
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: Card(
        color: Theme.of(context).colorScheme.primary,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: recommendedPlace.when(
          data: (data) => _buildRecommendation(context, data.item1, data.item2),
          error: (error, _) => Center(child: Text(error.toString(), style: const TextStyle(color: Colors.white))),
          loading: () => const CCPI(),
        ),
      ),
    );
  }

  Widget _buildRecommendation(BuildContext context, Place place, double distance) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colors.white,
                        overflow: TextOverflow.ellipsis,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  place.code.formatted,
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        color: Colors.white,
                        overflow: TextOverflow.ellipsis,
                      ),
                ),
              ],
            ),
            const Spacer(),
            Text(distance.toStringAsFixed(1) + ' M', style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white)),
          ],
        ),
      ),
      onTap: () => sendMessage(place.message),
    );
  }
}

class PlaceCard extends ConsumerWidget {
  final Place place;
  const PlaceCard({Key? key, required this.place}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditMode = ref.watch(isEditModeProvider);
    return ShakeWidget(
      duration: const Duration(seconds: 1),
      shakeConstant: ShakeLittleConstant1(),
      autoPlay: isEditMode,
      enableWebMouseHover: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: InkWell(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          overflow: TextOverflow.ellipsis,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    place.code.formatted,
                    style: Theme.of(context).textTheme.caption!.copyWith(
                          overflow: TextOverflow.ellipsis,
                        ),
                  ),
                ],
              ),
            ),
            onTap: () => _onCardTap(context, isEditMode),
          ),
        ),
      ),
    );
  }

  void _onCardTap(BuildContext context, bool isEditMode) {
    if (isEditMode) {
      _editPlace(context);
    } else {
      sendMessage(place.message);
    }
  }

  void _editPlace(BuildContext context) {}
}

class AddCard extends ConsumerWidget {
  const AddCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditMode = ref.watch(isEditModeProvider);
    return Visibility(
      visible: isEditMode,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: InkWell(
            child: const Center(
              child: Icon(Icons.add),
            ),
            onTap: () => _addPlace(context, ref),
          ),
        ),
      ),
    );
  }

  void _addPlace(BuildContext context, WidgetRef ref) async {
    final records = ref.watch(recordsProvider);
    if (records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scan a QR code first, then press add to add it to favorites.'),
        ),
      );
      return;
    }

    final recordIndex = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Add to Favorites'),
        children: records
            .asMap()
            .entries
            .map(
              (entry) => RecordOption(
                record: entry.value,
                onTap: () => Navigator.of(context).pop(entry.key),
              ),
            )
            .toList(),
      ),
    );

    if (recordIndex == null) {
      return;
    }

    final controller = TextEditingController();
    final placeName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Place'),
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter a name for this place',
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () => Navigator.of(context).pop(controller.text),
          ),
        ],
      ),
    );

    if (placeName == null) {
      return;
    }

    final recordsNotifier = ref.read(recordsProvider.notifier);
    final placesNotifer = ref.read(placesProvider.notifier);
    placesNotifer.add(Place.fromRecord(records[recordIndex], placeName));
    recordsNotifier.deleteAt(recordIndex);
  }
}

class RecordOption extends StatelessWidget {
  final Record record;
  final void Function() onTap;
  const RecordOption({Key? key, required this.record, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(DateFormat('M/d - hh:mm a').format(record.time)),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(record.code.formatted),
      ),
      onTap: () => Navigator.of(context).pop(0),
    );
  }
}
