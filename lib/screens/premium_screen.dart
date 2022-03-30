import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lazy1922/consts.dart';
import 'package:lazy1922/models/lazy_purchase_error.dart';
import 'package:lazy1922/providers/user_provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vrouter/vrouter.dart';
import 'package:easy_localization/easy_localization.dart';

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
        onPressed: () => context.vRouter.pop(),
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
        FeatureTile(
          title: 'favorite_places'.tr(),
          subtitle: 'favorite_places_subtitle'.tr(),
          leading: Icons.favorite_outline,
          onTap: () => _showFeatureCard(context, title: 'favorite_places'.tr(), description: 'favorite_places_description'.tr()),
        ),
        FeatureTile(
          title: 'smart_suggestions'.tr(),
          subtitle: 'smart_suggestions_subtitle'.tr(),
          leading: Icons.location_on_outlined,
          onTap: () => _showFeatureCard(context, title: 'smart_suggestions'.tr(), description: 'smart_suggestions_description'.tr()),
        ),
        FeatureTile(
          title: 'home_widgets'.tr(),
          subtitle: 'home_widgets_subtitle'.tr(),
          leading: Icons.dashboard_outlined,
        ),
        FeatureTile(
          title: 'backup_and_restore'.tr(),
          subtitle: 'backup_and_restore_subtitle'.tr(),
          leading: Icons.save_alt_outlined,
        ),
      ]),
    );
  }

  void _showFeatureCard(BuildContext context, {required String title, required String description}) {
    showFlexibleBottomSheet(
      context: context,
      initHeight: featureModalHeightRatio,
      maxHeight: featureModalHeightRatio,
      isDismissible: false,
      anchors: [0, featureModalHeightRatio],
      builder: (context, controller, __) => FeatureSheet(
        title: title,
        description: description,
        scrollController: controller,
      ),
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
    String? errorMessage;
    try {
      await userNotifier.upgradeToPro(package);
      Geolocator.requestPermission();
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

class FeatureTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData leading;
  final void Function()? onTap;
  const FeatureTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.leading,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(leading, color: Colors.grey.shade700),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 18),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.caption!.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade700,
              ),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class FeatureSheet extends StatelessWidget {
  final String title;
  final String description;
  final ScrollController scrollController;
  const FeatureSheet({Key? key, required this.title, required this.description, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Material(
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildCloseBar(context),
              Text(
                title,
                style: Theme.of(context).textTheme.headline4!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 24),
                child: Text(
                  description,
                  style: Theme.of(context).textTheme.caption!.copyWith(fontSize: 16),
                  textAlign: TextAlign.start,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * featureModalHeightRatio * 0.72,
                child: Center(child: Text('some picture here')),
              )
            ],
          ),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
    );
  }

  Widget _buildCloseBar(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: IconButton(
            icon: const Icon(Icons.clear),
            splashRadius: 20,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}
