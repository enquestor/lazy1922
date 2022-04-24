import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lazy1922/models/lazy_error.dart';
import 'package:lazy1922/models/place.dart';
import 'package:lazy1922/models/record.dart';
import 'package:lazy1922/models/selected_page.dart';
import 'package:lazy1922/providers/pending_message_provider.dart';
import 'package:lazy1922/providers/places_provider.dart';
import 'package:lazy1922/providers/user_provider.dart';
import 'package:lazy1922/utils.dart';
import 'package:lazy1922/widgets/ccpi.dart';
import 'package:lazy1922/widgets/edit_place_dialog.dart';
import 'package:tuple/tuple.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

final _isEditModeProvider = StateProvider.autoDispose<bool>((ref) => false);
final suggestedPlaceProvider = FutureProvider.autoDispose<Tuple2<Place, double>>((ref) async {
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

  final suggestedPlace = places.first;
  final distance = Geolocator.distanceBetween(suggestedPlace.latitude, suggestedPlace.longitude, location.latitude, location.longitude);
  final suggestionRange = ref.watch(userProvider).suggestionRange;
  if (distance > suggestionRange) {
    throw LazyError.noSuggestionInRange;
  }
  return Tuple2(suggestedPlace, distance);
});

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(placesProvider);
    final showAddPlaceGuide = places.isEmpty;
    final body = Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Suggestion(),
          const SizedBox(height: 32),
          showAddPlaceGuide ? _buildAddPlaceGuide() : const Favorites(),
        ],
      ),
    );

    if (showAddPlaceGuide) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: body,
        floatingActionButton: _buildFloatingActionButton(context, ref),
      );
    } else {
      return Scaffold(
        appBar: _buildAppBar(),
        body: SingleChildScrollView(child: body),
        floatingActionButton: _buildFloatingActionButton(context, ref),
      );
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(title: Text('home'.tr()));
  }

  Expanded _buildAddPlaceGuide() {
    return Expanded(
      child: Center(
        child: Text('add_favorites_guide'.tr()),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, WidgetRef ref) {
    final isEditMode = ref.watch(_isEditModeProvider);
    return FloatingActionButton(
      onPressed: () => _onFabPressed(context, ref),
      child: isEditMode ? const Icon(Icons.close) : const Icon(Icons.edit),
    );
  }

  void _onFabPressed(BuildContext context, WidgetRef ref) async {
    final isEditMode = ref.read(_isEditModeProvider);
    final isEditModeNotifier = ref.read(_isEditModeProvider.notifier);
    final places = ref.read(placesProvider);

    if (places.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('add_place_first'.tr())));
      return;
    }

    if (isEditMode) {
      isEditModeNotifier.state = false;
    } else {
      isEditModeNotifier.state = true;
    }
  }
}

class Favorites extends ConsumerWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(placesProvider);
    final isEditMode = ref.watch(_isEditModeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeTitle(title: 'favorites'.tr()),
        ReorderableBuilder(
          enableDraggable: isEditMode,
          enableLongPress: true,
          dragChildBoxDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          children: List<Widget>.from(places.map((place) => PlaceCard(key: Key(place.hashCode.toString()), place: place)).toList()),
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
        ),
      ],
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

class Suggestion extends ConsumerStatefulWidget {
  const Suggestion({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SuggestionState();
}

class _SuggestionState extends ConsumerState<Suggestion> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.refresh(suggestedPlaceProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestedPlace = ref.watch(suggestedPlaceProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeTitle(title: 'suggestion'.tr()),
        SizedBox(
          height: 160,
          width: double.infinity,
          child: Card(
            color: Theme.of(context).colorScheme.primary,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: suggestedPlace.when(
              data: (data) => _buildSuggestionCard(data.item1, data.item2),
              error: (error, _) => _buildScanCard(),
              loading: () => const CCPI(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(Place place, double distance) {
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
            Text(
              'meter'.plural(distance.round()),
              style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
      onTap: () {
        final pendingMessageNotifier = ref.read(pendingMessageProvider.notifier);
        pendingMessageNotifier.state = Record.fromPlace(place);
        context.go('/${EnumToString.convertToString(SelectedPage.messages)}');
      },
    );
  }

  Widget _buildScanCard() {
    return InkWell(
      child: const Icon(Icons.camera_alt_outlined, color: Colors.white),
      onTap: () => context.go('/${EnumToString.convertToString(SelectedPage.scan)}'),
    );
  }
}

class PlaceCard extends ConsumerWidget {
  final Place place;
  const PlaceCard({Key? key, required this.place}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditMode = ref.watch(_isEditModeProvider);
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
      final pendingMessageNotifier = ref.read(pendingMessageProvider.notifier);
      pendingMessageNotifier.state = Record.fromPlace(place);
      context.go('/${EnumToString.convertToString(SelectedPage.messages)}');
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
        onDelete: () {
          placesNotifier.remove(place);
          final places = ref.read(placesProvider);
          if (places.isEmpty) {
            final isEditModeNotifier = ref.read(_isEditModeProvider.notifier);
            isEditModeNotifier.state = false;
          }
        },
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
        child: Text(DateFormat('M/d - hh:mm a', context.locale.toString()).format(record.time)),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(record.code.formatted),
      ),
      onTap: () => Navigator.of(context).pop(0),
    );
  }
}
