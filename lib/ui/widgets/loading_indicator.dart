import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/theme/theme.dart';

/// A reusable loading indicator widget
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const LoadingIndicator({
    Key? key,
    this.size = 40.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? RaceColors.primary,
          ),
        ),
      ),
    );
  }
} 