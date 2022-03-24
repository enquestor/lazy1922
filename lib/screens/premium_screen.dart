import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazy1922/providers/user_provider.dart';
import 'package:vrouter/vrouter.dart';
import 'package:easy_localization/easy_localization.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      child: Column(
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
          _buildUpgradeBar(context, ref),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
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
          padding: const EdgeInsets.only(left: 24, right: 24, top: 60, bottom: 60),
          child: Text(
            'upgrade_premium_message'.tr(),
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        FunctionTile(
          title: 'favorite_places'.tr(),
          subtitle: 'favorite_places_description'.tr(),
          leading: Icons.favorite_outline,
          onTap: () => {},
        ),
        FunctionTile(
          title: 'smart_suggestions'.tr(),
          subtitle: 'smart_suggestions_description'.tr(),
          leading: Icons.location_on_outlined,
          onTap: () => {},
        ),
        FunctionTile(
          title: 'home_widgets'.tr(),
          subtitle: 'home_widgets_description'.tr(),
          leading: Icons.dashboard_outlined,
        ),
        FunctionTile(
          title: 'backup_and_restore'.tr(),
          subtitle: 'backup_and_restore_description'.tr(),
          leading: Icons.save_alt_outlined,
        ),
      ]),
    );
  }

  Widget _buildUpgradeBar(BuildContext context, WidgetRef ref) {
    final userNotifier = ref.read(userProvider.notifier);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Row(
        children: [
          Text(
            '\$30',
            style: Theme.of(context).textTheme.headline4!.copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'one_time_purchase'.tr(),
              style: Theme.of(context).textTheme.caption!.copyWith(fontSize: 14),
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 48,
            width: 96,
            child: ElevatedButton(
              child: Text('upgrade'.tr()),
              onPressed: () => userNotifier.upgradeToPro(),
            ),
          ),
        ],
      ),
    );
  }
}

class FunctionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData leading;
  final void Function()? onTap;
  const FunctionTile({
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
