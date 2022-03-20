class User {
  final bool initialized;
  final bool isPro;

  const User({
    required this.initialized,
    required this.isPro,
  });

  factory User.template() {
    return const User(
      initialized: false,
      isPro: false,
    );
  }

  User copyWith({
    bool? initialized,
    bool? isPro,
  }) {
    return User(
      initialized: initialized ?? this.initialized,
      isPro: isPro ?? this.isPro,
    );
  }
}
