import 'package:flutter/material.dart';

class DialogListTile extends StatelessWidget {
  final Widget title;
  final void Function() onTap;
  const DialogListTile({Key? key, required this.title, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: title,
      ),
      onTap: onTap,
    );
  }
}
