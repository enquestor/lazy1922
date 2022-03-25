import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 3)
class User {
  @HiveField(0, defaultValue: false)
  final bool isPro;
  @HiveField(1, defaultValue: 200)
  final int recommendationRange;

  const User({
    required this.isPro,
    required this.recommendationRange,
  });

  factory User.template() {
    return const User(
      isPro: false,
      recommendationRange: 200,
    );
  }

  User copyWith({
    bool? isPro,
    int? recommendationRange,
  }) {
    return User(
      isPro: isPro ?? this.isPro,
      recommendationRange: recommendationRange ?? this.recommendationRange,
    );
  }
}
