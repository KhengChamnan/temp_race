import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/theme/theme.dart';

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: RaceColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Text(
        'RACE CONTROL',
        style: RaceTextStyles.body.copyWith(
          color: RaceColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
