import 'package:flutter/material.dart';

AppBarTheme appBarTheme(BuildContext context, Brightness brightness) => AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: Theme.of(context).textTheme.headline6!.copyWith(color: brightness == Brightness.light ? Colors.black : Colors.white),
      iconTheme: IconThemeData(
        color: Colors.grey,
      ),
    );

const darkAppBarTheme = AppBarTheme(
  backgroundColor: Colors.transparent,
  elevation: 0,
  centerTitle: true,
  titleTextStyle: TextStyle(color: Colors.white),
  iconTheme: IconThemeData(
    color: Colors.grey,
  ),
);

final cardTheme = CardTheme(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24),
  ),
  elevation: 4,
);

final dialogTheme = DialogTheme(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24),
  ),
);

const floatingActionButtonTheme = FloatingActionButtonThemeData(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
);

final inputDecorationTheme = InputDecorationTheme(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
  ),
);

final textButtonTheme = TextButtonThemeData(
  style: TextButton.styleFrom(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

final elevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

final outlinedButtonTheme = OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
