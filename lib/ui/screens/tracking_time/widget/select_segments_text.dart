import 'package:flutter/material.dart';

class SelectSegmentsText extends StatelessWidget {
  const SelectSegmentsText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 5),
      child: Text(
        'Select Segments',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}