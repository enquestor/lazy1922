import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazy1922/providers/data_provider.dart';
import 'package:lazy1922/providers/user_provider.dart';
import 'package:lazy1922/routes.dart';
import 'package:lazy1922/screens/home_screen.dart';
import 'package:vrouter/vrouter.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        final userNotifier = ref.read(userProvider.notifier);
        final dataNotifier = ref.read(dataProvider.notifier);
        userNotifier.save();
        dataNotifier.save();
        break;
      default:
        break;
    }
  }

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
      ),
      initialUrl: Routes.home,
      routes: [
        VWidget(
          path: Routes.home,
          widget: HomeScreen(),
        )
      ],
    );
  }
}
