import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lazy1922/models/lazy_error.dart';
import 'package:lazy1922/models/place.dart';
import 'package:lazy1922/providers/data_provider.dart';
import 'package:lazy1922/providers/is_edit_mode_provider.dart';
import 'package:lazy1922/utils.dart';
import 'package:lazy1922/widgets/ccpi.dart';
import 'package:tuple/tuple.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dataProvider);

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
            MasonryGridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemCount: data.places.length,
              itemBuilder: (context, index) => PlaceCard(place: data.places[index]),
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
  final data = ref.watch(dataProvider);
  if (data.places.isEmpty) {
    throw LazyError.noSavedPlaces;
  }

  final location = await getLocation();
  data.places.sort((a, b) {
    final distanceA = Geolocator.distanceBetween(a.latitude, a.longitude, location.latitude, location.longitude);
    final distanceB = Geolocator.distanceBetween(b.latitude, b.longitude, location.latitude, location.longitude);
    return distanceA.compareTo(distanceB);
  });

  final recommendedPlace = data.places.first;
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
      child: SizedBox(
        height: 140,
        width: double.infinity,
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
            onTap: () => sendMessage(place.message),
          ),
        ),
      ),
    );
  }
}
