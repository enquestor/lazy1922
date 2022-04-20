import 'package:easy_localization/easy_localization.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:go_router/go_router.dart';
import 'package:lazy1922/models/selected_page.dart';
import 'package:lazy1922/providers/user_provider.dart';
import 'package:lazy1922/screens/premium_screen.dart';
import 'package:lazy1922/widgets/feature.dart';

class IntroductionScreen extends ConsumerWidget {
  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: IntroSlider(
        slides: [
          Slide(
            title: 'lazy1922'.tr(),
            centerWidget: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 180,
                      child: Text(
                        'welcome_to_lazy1922'.tr(),
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    CheckRow(title: 'no_ads'.tr()),
                    CheckRow(title: '1922_qr_codes_only'.tr()),
                    CheckRow(title: 'send_immediately'.tr()),
                  ],
                ),
              ),
            ),
            styleTitle: Theme.of(context).textTheme.headline4!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
            styleDescription: Theme.of(context).textTheme.headline6,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          Slide(
            title: '進階功能',
            centerWidget: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    height: 180,
                    child: Text(
                      '購買付費版本解鎖進階功能，讓你在符合政府規範下，實現「完全不掃」實聯制！',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  const Feature(
                    name: 'favorite_places',
                    icon: Icons.favorite_outline,
                    demo: FavoritePlacesDemo(),
                  ),
                  const Feature(
                    name: 'smart_suggestions',
                    icon: Icons.location_on_outlined,
                    demo: SmartSuggestionDemo(),
                  ),
                  const Feature(
                    name: 'message_history',
                    icon: Icons.message_outlined,
                    demo: MessageHistoryDemo(),
                  ),
                  const Feature(
                    name: 'backup_and_restore',
                    icon: Icons.save_alt_outlined,
                  ),
                ],
              ),
            ),
            styleTitle: Theme.of(context).textTheme.headline4!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
        ],
        renderSkipBtn: Text(
          'skip'.tr(),
          style: Theme.of(context).textTheme.button,
        ),
        renderNextBtn: Text(
          'next'.tr(),
          style: Theme.of(context).textTheme.button,
        ),
        renderDoneBtn: Text(
          'done'.tr(),
          style: Theme.of(context).textTheme.button,
        ),
        onDonePress: () async {
          final useTrial = await showDialog<bool>(
            barrierDismissible: false,
            context: context,
            builder: (context) => AlertDialog(
              title: Text('try_lazy1922_premium'.tr()),
              content: Text('try_lazy1922_premium_message'.tr()),
              actions: [
                TextButton(
                  child: Text('no'.tr()),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text('sure'.tr()),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          );

          final userNotifier = ref.read(userProvider.notifier);
          if (useTrial!) {
            userNotifier.startTrial();
            Geolocator.requestPermission();
          }

          userNotifier.setNotNewUser();
          context.go('/${EnumToString.convertToString(SelectedPage.home)}');
        },
        onSkipPress: () {
          final userNotifier = ref.read(userProvider.notifier);
          userNotifier.setNotNewUser();
          context.go('/${EnumToString.convertToString(SelectedPage.home)}');
        },
      ),
    );
  }
}

class CheckRow extends StatelessWidget {
  final String title;
  const CheckRow({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Icon(
            Icons.check,
            size: 32,
          ),
          const SizedBox(width: 24),
          Text(title, style: Theme.of(context).textTheme.headline6),
        ],
      ),
    );
  }
}
