import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lazy1922/models/user.dart';

class UserNotifer extends StateNotifier<User> {
  Box<User> get box => Hive.box<User>('users');

  UserNotifer() : super(Hive.box<User>('users').get('user') ?? User.template()) {
    state = state;
  }

  @override
  set state(User value) {
    super.state = value;
    box.put('user', value);
  }

  void upgradeToPro() async {
    state = state.copyWith(isPro: true);
  }

  void setRecommendationRange(int range) {
    state = state.copyWith(recommendationRange: range);
  }
}

final userProvider = StateNotifierProvider<UserNotifer, User>((ref) => UserNotifer());
