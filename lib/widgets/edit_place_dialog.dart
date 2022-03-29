import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lazy1922/models/place.dart';

class EditPlaceDialog extends StatelessWidget {
  final Place place;
  final bool isAdd;
  final void Function(Place place) onConfirm;
  final void Function()? onDelete;
  const EditPlaceDialog({
    Key? key,
    required this.place,
    required this.onConfirm,
    this.onDelete,
    this.isAdd = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _nameController = TextEditingController(text: place.name);
    return AlertDialog(
      title: Text(isAdd ? 'add_place'.tr() : 'edit_place'.tr()),
      content: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'name'.tr()),
        ),
      ),
      actions: [
        Visibility(
          visible: !isAdd,
          child: TextButton(
            child: Text('delete'.tr(), style: const TextStyle(color: Colors.red)),
            style: ButtonStyle(overlayColor: MaterialStateProperty.all(Colors.red.withOpacity(0.2))),
            onPressed: () {
              if (onDelete != null) {
                onDelete!();
              }
              Navigator.of(context).pop();
            },
          ),
        ),
        TextButton(
          child: Text('ok'.tr()),
          onPressed: () {
            onConfirm(place.copyWith(name: _nameController.text));
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
