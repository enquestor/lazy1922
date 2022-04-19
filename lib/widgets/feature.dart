import 'dart:io';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:device_frame/device_frame.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lazy1922/consts.dart';

class Feature extends StatelessWidget {
  final String name;
  final IconData icon;
  final Widget? demo;

  const Feature({
    Key? key,
    required this.name,
    required this.icon,
    this.demo,
  }) : super(key: key);

  String get title => name.tr();
  String get subtitle => '${name}_subtitle'.tr();
  String get description => '${name}_description'.tr();

  @override
  Widget build(BuildContext context) {
    return FeatureTile(
      title: name.tr(),
      subtitle: '${name}_subtitle'.tr(),
      leading: icon,
      onTap: demo == null ? null : () => _showFeatureCard(context),
    );
  }

  void _showFeatureCard(BuildContext context) {
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
        demo: demo!,
      ),
    );
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
      child: Material(
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
      ),
    );
  }
}

class FeatureSheet extends StatelessWidget {
  final String title;
  final String description;
  final Widget demo;
  final ScrollController scrollController;
  const FeatureSheet({
    Key? key,
    required this.title,
    required this.description,
    required this.demo,
    required this.scrollController,
  }) : super(key: key);

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
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 24,
                  bottom: MediaQuery.of(context).size.height * featureModalHeightRatio * 0.06,
                ),
                child: Text(
                  description,
                  style: Theme.of(context).textTheme.caption!.copyWith(fontSize: 16),
                  textAlign: TextAlign.start,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * featureModalHeightRatio * 0.60,
                child: DeviceFrame(
                  device: Platform.isIOS ? Devices.ios.iPhone13ProMax : Devices.android.samsungGalaxyS20,
                  screen: Builder(
                    builder: (context) => MaterialApp(
                      useInheritedMediaQuery: true,
                      theme: Theme.of(context),
                      home: demo,
                    ),
                  ),
                ),
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
