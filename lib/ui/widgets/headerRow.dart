import 'package:flutter/material.dart';

class HeaderRow extends StatelessWidget {
  final String title;
  final int flex;

  const HeaderRow({super.key, required this.title, required this.flex});  

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}
