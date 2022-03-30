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

  const User({
    required this.isRealPremium,
    required this.suggestionRange,
    this.trial,
    required this.autoReturn,
  });

  factory User.template() {
    return const User(
      isRealPremium: false,
      suggestionRange: defaultSuggestionRange,
      autoReturn: defaultAutoReturn,
    );
  }

  User copyWith({
    bool? isRealPremium,
    int? suggestionRange,
    DateTime? trial,
    int? autoReturn,
  }) {
    return User(
      isRealPremium: isRealPremium ?? this.isRealPremium,
      suggestionRange: suggestionRange ?? this.suggestionRange,
      trial: trial ?? this.trial,
      autoReturn: autoReturn ?? this.autoReturn,
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
