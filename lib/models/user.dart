import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 3)
class User {
  @HiveField(0, defaultValue: false)
  final bool isPro;

  const User({
    required this.isPro,
  });

  factory User.template() {
    return const User(
      isPro: false,
    );
  }

  User copyWith({
    bool? isPro,
  }) {
    return User(
      isPro: isPro ?? this.isPro,
    );
  }
}
