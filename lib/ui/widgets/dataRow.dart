import 'package:flutter/material.dart';

class DataInRow extends StatelessWidget {
  final String text;
  final int flex;

  const DataInRow({super.key, required this.text, required this.flex});  

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}
