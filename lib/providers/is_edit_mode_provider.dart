import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazy1922/providers/selected_page_provider.dart';

final isEditModeProvider = StateProvider<bool>((ref) {
  ref.watch(selectedPageProvider);
  return false;
});
