import 'package:lazy1922/models/default_page.dart';
import 'package:lazy1922/models/location_mode.dart';
import 'package:lazy1922/models/location_sensitivity.dart';

class User {
  final bool initialized;
  final bool isPro;

  const User({
    required this.initialized,
    required this.isPro,
  });

  factory User.template() {
    return const User(
      initialized: false,
      isPro: false,
    );
  }

  User copyWith({
    bool? initialized,
    bool? isPro,
  }) {
    return User(
      initialized: initialized ?? this.initialized,
      isPro: isPro ?? this.isPro,
    );
  }
}
