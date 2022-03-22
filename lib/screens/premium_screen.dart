import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazy1922/providers/user_provider.dart';
import 'package:vrouter/vrouter.dart';
import 'package:easy_localization/easy_localization.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userNotifier = ref.read(userProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text('lazy1922_premium'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.clear),
          splashRadius: 20,
          onPressed: () => context.vRouter.pop(),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'upgrade'.tr(),
              style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.white, fontSize: 20),
            ),
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => userNotifier.upgradeToPro(),
        ),
      ),
    );
  }
}
