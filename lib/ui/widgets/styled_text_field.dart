import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/theme/theme.dart';

class StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int flex;
  final TextInputType keyboardType;
  final TextAlign textAlign;

  const StyledTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.flex = 1,
    this.keyboardType = TextInputType.text,
    this.textAlign = TextAlign.left,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: RaceColors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          textAlign: textAlign,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            border: InputBorder.none,
            hintText: hintText,
          ),
        ),
      ),
    );
  }
}

class StyledDisplayField extends StatelessWidget {
  final String text;
  final int flex;
  final EdgeInsetsGeometry padding;
  final TextAlign textAlign;

  const StyledDisplayField({
    Key? key,
    required this.text,
    this.flex = 1,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    this.textAlign = TextAlign.left,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          border: Border.all(color: RaceColors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: textAlign == TextAlign.left 
            ? Alignment.centerLeft 
            : (textAlign == TextAlign.right 
                ? Alignment.centerRight 
                : Alignment.center),
        child: Text(text),
      ),
    );
  }
} 