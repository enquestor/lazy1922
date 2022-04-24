import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lazy1922/models/lazy_purchase_error.dart';
import 'package:lazy1922/pages/home/home_page.dart';
import 'package:lazy1922/pages/home/messages_page.dart';
import 'package:lazy1922/pages/premium/demo_page.dart';
import 'package:lazy1922/providers/user_provider.dart';
import 'package:lazy1922/widgets/feature.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

final _packageProvider = FutureProvider.autoDispose<Package>((ref) async {
  Offerings offerings = await Purchases.getOfferings();
  final offering = offerings.current;
  if (offering == null) {
    throw LazyPurchaseError.noOffering;
  }

  final package = offering.getPackage('premium');
  if (package == null) {
    throw LazyPurchaseError.noPackage;
  }

  return package;
});
final _isPurchasingProvider = StateProvider.autoDispose<bool>((ref) => false);

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final package = ref.watch(_packageProvider);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                _buildFeatureList(context),
              ],
            ),
          ),
          package.when(
            data: (data) => _buildUpgradeBar(context, ref, data),
            error: (error, _) => _buildUpgradeBar(context, ref),
            loading: () => _buildUpgradeBar(context, ref),
          )
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: const Icon(Icons.chevron_left, color: Colors.white),
        splashRadius: 20,
        onPressed: () => context.pop(),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.teal.shade300,
              Colors.teal.shade500,
              Colors.teal.shade600,
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          title: Text('lazy1922_premium'.tr()),
          centerTitle: true,
        ),
      ),
      pinned: true,
      expandedHeight: 160,
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 32),
          child: Text(
            'upgrade_premium_message'.tr(),
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        const Feature(
          name: 'favorite_places',
          icon: Icons.favorite_outline,
          demo: FavoritePlacesDemo(),
        ),
        const Feature(
          name: 'smart_suggestions',
          icon: Icons.location_on_outlined,
          demo: SmartSuggestionDemo(),
        ),
        const Feature(
          name: 'message_history',
          icon: Icons.message_outlined,
          demo: MessageHistoryDemo(),
        ),
        const Feature(
          name: 'backup_and_restore',
          icon: Icons.save_alt_outlined,
        ),
      ]),
    );
  }

  Widget _buildUpgradeBar(BuildContext context, WidgetRef ref, [Package? package]) {
    final user = ref.watch(userProvider);
    final isPurchasing = ref.watch(_isPurchasingProvider);
    final isLoading = package == null;
    final isActionAvailable = !(isLoading || isPurchasing);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: user.isTrialAvailable
                  ? OutlinedButton(
                      child: Text('trial'.tr()),
                      onPressed: isActionAvailable ? () => _trial(context, ref) : null,
                    )
                  : OutlinedButton(
                      child: Text('share'.tr()),
                      onPressed: () => _share(),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                child: Text(user.isRealPremium ? 'purchased'.tr() : 'upgrade'.tr()),
                onPressed: isActionAvailable && !user.isRealPremium ? () => _upgrade(context, ref, package) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _upgrade(BuildContext context, WidgetRef ref, Package package) async {
    final isPurchasingNotifier = ref.read(_isPurchasingProvider.notifier);
    isPurchasingNotifier.state = true;

    final userNotifier = ref.read(userProvider.notifier);

    final supportDeveloper = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('upgrade'.tr()),
        content: Text('upgrade_message'.tr()),
        actions: [
          TextButton(
            child: Text('cancel'.tr()),
            onPressed: () => Navigator.of(context).pop(null),
          ),
          TextButton(
            child: Text('free_upgrade'.tr()),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('buy_me_a_drink'.tr()),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (supportDeveloper != null) {
      if (supportDeveloper) {
        String? errorMessage;
        try {
          await userNotifier.upgradeToPro(package);
        } catch (e) {
          if (e is PlatformException) {
            var errorCode = PurchasesErrorHelper.getErrorCode(e);
            if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
              errorMessage = 'purchase_cancelled'.tr();
            } else {
              errorMessage = 'unknown_error'.tr();
            }
          } else {
            errorMessage = 'unknown_error'.tr();
          }
        }

        if (errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      } else {
        userNotifier.freeUpgrade();
      }
      Geolocator.requestPermission();
    }

    isPurchasingNotifier.state = false;
  }

  void _trial(BuildContext context, WidgetRef ref) async {
    final userNotifier = ref.read(userProvider.notifier);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('trial'.tr()),
        content: Text('trial_message'.tr()),
        actions: [
          TextButton(child: Text('ok'.tr()), onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );

    userNotifier.startTrial();
    Geolocator.requestPermission();
  }

  void _share() async {
    Share.share('share_message'.tr());
  }
}

class FavoritePlacesDemo extends StatelessWidget {
  const FavoritePlacesDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      child: Scaffold(
        appBar: AppBar(title: Text('home'.tr())),
        body: const Padding(
          padding: EdgeInsets.all(18),
          child: Favorites(),
        ),
      ),
    );
  }
}

class SmartSuggestionDemo extends StatelessWidget {
  const SmartSuggestionDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      child: Scaffold(
        appBar: AppBar(title: Text('home'.tr())),
        body: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: const [
              Suggestion(),
              SizedBox(height: 32),
              Favorites(),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageHistoryDemo extends StatelessWidget {
  const MessageHistoryDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const DemoPage(
      child: MessagesPage(),
    );
  }
}
