import 'package:flutter/material.dart';

class CCPI extends StatelessWidget {
  const CCPI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.white,
      ),
    );
  }
}
