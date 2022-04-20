import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lazy1922/consts.dart';
import 'package:lazy1922/models/lazy_purchase_error.dart';
import 'package:lazy1922/models/user.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

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

  Future<void> upgradeToPro(Package package) async {
    PurchaserInfo purchaserInfo = await Purchases.purchasePackage(package);
    if (purchaserInfo.entitlements.all["premium"]!.isActive) {
      state = state.copyWith(isRealPremium: true);
    } else {
      throw LazyPurchaseError.premiumNotActive;
    }
  }

  void setAutoReturn(int autoReturn) {
    state = state.copyWith(autoReturn: autoReturn);
  }

  void setSuggestionRange(int range) {
    state = state.copyWith(suggestionRange: range);
  }

  void startTrial() {
    state = state.copyWith(trial: DateTime.now().add(const Duration(days: trialDays)));
  }

  void fakeUpgrade() {
    state = state.copyWith(isRealPremium: true);
  }

  void setNotNewUser() {
    state = state.copyWith(isNewUser: false);
  }

  void setTrialEndedMessageShown() {
    state = state.copyWith(isTrialEndMessageShown: true);
  }
}

final userProvider = StateNotifierProvider<UserNotifer, User>((ref) => UserNotifer());
