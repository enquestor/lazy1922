import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lazy1922/models/code.dart';
import 'package:lazy1922/models/place.dart';
import 'package:lazy1922/models/record.dart';
import 'package:lazy1922/models/user.dart';
import 'package:lazy1922/screens/home_screen.dart';
import 'package:lazy1922/screens/premium_screen.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:vrouter/vrouter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive
    ..registerAdapter<Code>(CodeAdapter())
    ..registerAdapter<Record>(RecordAdapter())
    ..registerAdapter<Place>(PlaceAdapter())
    ..registerAdapter<User>(UserAdapter());
  await Future.wait([
    Hive.openBox<List>("records"),
    Hive.openBox<List>("places"),
    Hive.openBox<User>("users"),
    dotenv.load(fileName: ".env"),
    EasyLocalization.ensureInitialized(),
  ]);

  Purchases.setDebugLogsEnabled(true);

  if (Platform.isAndroid) {
    Purchases.setup(dotenv.env['PUBLIC_GOOGLE_SDK_KEY']!);
  } else {
    Purchases.setup(dotenv.env['PUBLIC_IOS_SDK_KEY']!);
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('zh', 'TW'),
        // Locale('ja', 'JP'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: const ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VRouter(
      title: 'Lazy1922',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            titleTextStyle: Theme.of(context).textTheme.headline6,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(
              color: Theme.of(context).textTheme.headline6!.color,
            )),
        primarySwatch: Colors.teal,
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 4,
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      initialUrl: '/',
      routes: [
        VWidget(
          name: 'home',
          path: '/',
          widget: const HomeScreen(),
          stackedRoutes: [
            VWidget(
              name: 'premium',
              path: '/premium',
              widget: const PremiumScreen(),
            ),
          ],
        ),
      ],
    );
  }
}
