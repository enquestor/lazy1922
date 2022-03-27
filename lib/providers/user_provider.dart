import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
      state = state.copyWith(isPro: true);
    } else {
      throw LazyPurchaseError.premiumNotActive;
    }
  }

  void setRecommendationRange(int range) {
    state = state.copyWith(recommendationRange: range);
  }

  void fakeUpgrade() {
    state = state.copyWith(isPro: true);
  }
}

final userProvider = StateNotifierProvider<UserNotifer, User>((ref) => UserNotifer());
