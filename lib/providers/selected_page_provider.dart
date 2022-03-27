import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazy1922/models/selected_page.dart';
import 'package:lazy1922/providers/user_provider.dart';

final selectedPageProvider = StateProvider<SelectedPage>((ref) {
  final user = ref.read(userProvider);
  if (user.isPremium) {
    return SelectedPage.home;
  } else {
    return SelectedPage.scan;
  }
});
