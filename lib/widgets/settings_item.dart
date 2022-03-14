import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final String? value;
  final void Function()? onTap;
  const SettingsItem({
    Key? key,
    required this.title,
    this.value,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            title,
            style: TextStyle(fontSize: 18),
          ),
        ),
        subtitle: value == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(value!, style: TextStyle(fontSize: 16)),
              ),
        onTap: onTap,
      ),
    );
  }
}
