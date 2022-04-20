import 'package:hive/hive.dart';
import 'package:lazy1922/consts.dart';

part 'user.g.dart';

@HiveType(typeId: 3)
class User {
  @HiveField(0, defaultValue: false)
  final bool isRealPremium;
  @HiveField(1, defaultValue: defaultSuggestionRange)
  final int suggestionRange;
  @HiveField(2)
  final DateTime? trial;
  @HiveField(3, defaultValue: defaultAutoReturn)
  final int autoReturn;
  @HiveField(4, defaultValue: false)
  final bool isTrialEndMessageShown;
  @HiveField(5, defaultValue: true)
  final bool isNewUser;

  const User({
    required this.isRealPremium,
    required this.suggestionRange,
    this.trial,
    required this.autoReturn,
    required this.isTrialEndMessageShown,
    required this.isNewUser,
  });

  factory User.template() {
    return const User(
      isRealPremium: false,
      suggestionRange: defaultSuggestionRange,
      autoReturn: defaultAutoReturn,
      isTrialEndMessageShown: false,
      isNewUser: true,
    );
  }

  User copyWith({
    bool? isRealPremium,
    int? suggestionRange,
    DateTime? trial,
    int? autoReturn,
    bool? isTrialEndMessageShown,
    bool? isNewUser,
  }) {
    return User(
      isRealPremium: isRealPremium ?? this.isRealPremium,
      suggestionRange: suggestionRange ?? this.suggestionRange,
      trial: trial ?? this.trial,
      autoReturn: autoReturn ?? this.autoReturn,
      isTrialEndMessageShown: isTrialEndMessageShown ?? this.isTrialEndMessageShown,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }

  bool get isTrialAvailable => !isRealPremium && trial == null;
  bool get isTrialEnded => trial != null && DateTime.now().isAfter(trial!);

  bool get isPremium {
    if (isRealPremium) {
      return true;
    }

    if (!isTrialEnded) {
      return true;
    }

    return false;
  }
}
