import 'package:flutter/material.dart';

class SegmentButton extends StatelessWidget {
  final String segment;
  final bool isSelected;
  final VoidCallback onTap;

  const SegmentButton({
    Key? key,
    required this.segment,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: isSelected ? const Color(0xFFE8EAF6) : Colors.white,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              segment,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}