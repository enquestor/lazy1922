import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lazy1922/models/default_page.dart';
import 'package:lazy1922/models/location_mode.dart';
import 'package:lazy1922/models/location_sensitivity.dart';
import 'package:lazy1922/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserNotifer extends StateNotifier<User> {
  UserNotifer() : super(User.template()) {
    initialize();
  }

  void initialize() async {
    final prefs = await SharedPreferences.getInstance();

    state = state.copyWith(
      initialized: true,
      isPro: prefs.getBool('isPro'),
    );
  }

  void save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isPro', state.isPro);
  }

  void upgradeToPro() async {
    await Geolocator.requestPermission();

    state = state.copyWith(
      isPro: true,
    );
  }
}

final userProvider = StateNotifierProvider<UserNotifer, User>((ref) => UserNotifer());
