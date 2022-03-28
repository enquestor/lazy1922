import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lazy1922/models/lazy_error.dart';
import 'package:lazy1922/models/place.dart';
import 'package:lazy1922/models/record.dart';
import 'package:lazy1922/models/selected_page.dart';
import 'package:lazy1922/providers/is_edit_mode_provider.dart';
import 'package:lazy1922/providers/places_provider.dart';
import 'package:lazy1922/providers/records_provider.dart';
import 'package:lazy1922/providers/selected_page_provider.dart';
import 'package:lazy1922/providers/user_provider.dart';
import 'package:lazy1922/utils.dart';
import 'package:lazy1922/widgets/ccpi.dart';
import 'package:tuple/tuple.dart';
import 'package:easy_localization/easy_localization.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(placesProvider);
    final isEditMode = ref.watch(isEditModeProvider);
    final showAddPlaceGuide = places.isEmpty && !isEditMode;
    final child = Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeTitle(title: 'suggestion'.tr()),
          const RecommendationCard(),
          const SizedBox(height: 32),
          HomeTitle(title: 'favorites'.tr()),
          showAddPlaceGuide ? _buildAddPlaceGuide() : _buildPlacesList(ref),
        ],
      ),
    );
    if (showAddPlaceGuide) {
      return child;
    } else {
      return SingleChildScrollView(child: child);
    }
  }

  Widget _buildPlacesList(WidgetRef ref) {
    final isEditMode = ref.watch(isEditModeProvider);
    final places = ref.watch(placesProvider);
    final children = List<Widget>.from(places.map((place) => PlaceCard(key: Key(place.hashCode.toString()), place: place)).toList());
    return ReorderableBuilder(
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
        final placesNotifier = ref.read(placesProvider.notifier);
        for (var entity in orderUpdateEntities) {
          placesNotifier.move(entity.oldIndex, entity.newIndex);
        }
      },
      builder: (children, scrollController) => GridView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        controller: scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 4,
        ),
        children: children,
      ),
    );
  }

  Expanded _buildAddPlaceGuide() {
    return Expanded(
      child: Center(
        child: Text('add_favorites_guide'.tr()),
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
  // use toList to make full copy so that sort doesn't mess with provided list
  final places = ref.watch(placesProvider).toList();

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
  final recommendationRange = ref.watch(userProvider).recommendationRange;
  if (distance > recommendationRange) {
    throw LazyError.noRecommendationInRange;
  }
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
          data: (data) => _buildRecommendationCard(context, data.item1, data.item2),
          error: (error, _) => _buildScanCard(ref),
          loading: () => const CCPI(),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, Place place, double distance) {
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

  Widget _buildScanCard(WidgetRef ref) {
    final selectedPageNotifier = ref.read(selectedPageProvider.notifier);
    return InkWell(
      child: const Icon(Icons.camera_alt_outlined, color: Colors.white),
      onTap: () => selectedPageNotifier.state = SelectedPage.scan,
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
            onTap: () => _onCardTap(context, ref, isEditMode),
          ),
        ),
      ),
    );
  }

  void _onCardTap(BuildContext context, WidgetRef ref, bool isEditMode) {
    if (isEditMode) {
      _editPlace(context, ref);
    } else {
      sendMessage(place.message);
    }
  }

  void _editPlace(BuildContext context, WidgetRef ref) async {
    final placesNotifier = ref.read(placesProvider.notifier);
    showDialog(
      context: context,
      builder: (context) => EditPlaceDialog(
        place: place,
        onConfirm: (place) {
          if (place.name.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('name_cannot_be_empty'.tr())));
          } else {
            placesNotifier.edit(place);
          }
        },
        onDelete: () => placesNotifier.remove(place),
      ),
    );
  }
}

class EditPlaceDialog extends StatelessWidget {
  final Place place;
  final bool isAdd;
  final void Function(Place place) onConfirm;
  final void Function()? onDelete;
  const EditPlaceDialog({
    Key? key,
    required this.place,
    required this.onConfirm,
    this.onDelete,
    this.isAdd = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _nameController = TextEditingController(text: place.name);
    return AlertDialog(
      title: Text(isAdd ? 'add_place'.tr() : 'edit_place'.tr()),
      content: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'name'.tr()),
        ),
      ),
      actions: [
        Visibility(
          visible: !isAdd,
          child: TextButton(
            child: Text('delete'.tr(), style: const TextStyle(color: Colors.red)),
            style: ButtonStyle(overlayColor: MaterialStateProperty.all(Colors.red.withOpacity(0.2))),
            onPressed: () {
              if (onDelete != null) {
                onDelete!();
              }
              Navigator.of(context).pop();
            },
          ),
        ),
        TextButton(
          child: Text('ok'.tr()),
          onPressed: () {
            onConfirm(place.copyWith(name: _nameController.text));
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
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
    final places = ref.watch(placesProvider);
    final availableRecords = records.where((record) => places.where((place) => place.code == record.code).isEmpty).toList();
    if (availableRecords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no_available_records'.tr())),
      );
      return;
    }

    final index = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('select_record'.tr()),
        children: availableRecords
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

    if (index == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => EditPlaceDialog(
        place: Place.fromRecord(availableRecords[index], ''),
        onConfirm: (place) {
          if (place.name.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('name_cannot_be_empty'.tr())));
          } else {
            final placesNotifier = ref.read(placesProvider.notifier);
            placesNotifier.add(place);
          }
        },
        isAdd: true,
      ),
    );
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
