import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazy1922/models/selected_page.dart';
import 'package:lazy1922/providers/user_provider.dart';
import 'package:lazy1922/screens/home_screen.dart';
import 'package:lazy1922/screens/introduction_screen.dart';
import 'package:lazy1922/screens/premium_screen.dart';

final routerProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: '/home',
    // debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/:page',
        builder: (_, state) {
          final page = state.params['page'];
          if (page == 'introduction') {
            return const IntroductionScreen();
          }

          final selectedPage = EnumToString.fromString(SelectedPage.values, page!)!;
          return HomeScreen(selectedPage: selectedPage);
        },
        redirect: (state) {
          final user = ref.watch(userProvider);
          if (user.isNewUser && state.params['page'] != 'introduction') {
            return '/introduction';
          }

          if (!user.isPremium && state.params['page'] == 'home') {
            return '/scan';
          }
        },
        routes: [
          GoRoute(
            path: 'premium',
            builder: (_, __) => const PremiumScreen(),
          ),
        ],
      ),
    ],
  ),
);
