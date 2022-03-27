import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 3)
class User {
  @HiveField(0, defaultValue: false)
  final bool isRealPremium;
  @HiveField(1, defaultValue: 200)
  final int recommendationRange;
  @HiveField(2)
  final DateTime? trial;

  const User({
    required this.isRealPremium,
    required this.recommendationRange,
    this.trial,
  });

  factory User.template() {
    return const User(
      isRealPremium: false,
      recommendationRange: 200,
    );
  }

  User copyWith({
    bool? isRealPremium,
    int? recommendationRange,
    DateTime? trial,
  }) {
    return User(
      isRealPremium: isRealPremium ?? this.isRealPremium,
      recommendationRange: recommendationRange ?? this.recommendationRange,
      trial: trial ?? this.trial,
    );
  }

  bool get isPremium {
    if (isRealPremium) {
      return true;
    }

    if (trial != null && DateTime.now().isBefore(trial!)) {
      return true;
    }

    return false;
  }

  bool get isTrialAvailable => trial == null;
}
