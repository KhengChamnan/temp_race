import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/theme/theme.dart';

class ParticipantHeader extends StatelessWidget {
  const ParticipantHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: RaceColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Text(
        'PARTICIPANT',
        style: RaceTextStyles.body.copyWith(
          color: RaceColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}