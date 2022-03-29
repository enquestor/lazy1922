import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 3)
class User {
  @HiveField(0, defaultValue: false)
  final bool isRealPremium;
  @HiveField(1, defaultValue: 200)
  final int suggestionRange;
  @HiveField(2)
  final DateTime? trial;

  const User({
    required this.isRealPremium,
    required this.suggestionRange,
    this.trial,
  });

  factory User.template() {
    return const User(
      isRealPremium: false,
      suggestionRange: 200,
    );
  }

  User copyWith({
    bool? isRealPremium,
    int? suggestionRange,
    DateTime? trial,
  }) {
    return User(
      isRealPremium: isRealPremium ?? this.isRealPremium,
      suggestionRange: suggestionRange ?? this.suggestionRange,
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

  bool get isTrialAvailable => !isRealPremium && trial == null;
}
