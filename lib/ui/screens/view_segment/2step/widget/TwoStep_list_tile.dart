import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/theme/theme.dart';
import 'package:race_traking_app/ui/widgets/dataRow.dart';

class TwoStepListTile extends StatelessWidget {
  final String number;
  final String finishTime;
  final VoidCallback onSelectBib;
  final VoidCallback onReset;
  final bool isSelected;
  final bool isTemporary;
  final String? selectedBib;

  const TwoStepListTile({
    Key? key,
    required this.number,
    required this.finishTime,
    required this.onSelectBib,
    required this.onReset,
    this.isSelected = false,
    this.isTemporary = false,
    this.selectedBib,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isSelected 
          ? RaceColors.secondary 
          : isTemporary 
              ? RaceColors.secondary.withOpacity(0.2) 
              : Colors.transparent,
      child: Row(
        children: [
        SizedBox(width: RaceSpacings.s),
        DataInRow(
          text: number.padLeft(2, '0'),
          flex: 1,
        ),
        DataInRow(
          text: finishTime,
          flex: 2,
         
        ),
        Expanded(
          flex: 2,
          child: TextButton(
            onPressed: onSelectBib,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              textStyle: TextStyle(fontSize: RaceTextStyles.subbody.fontSize),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isTemporary && selectedBib == null
                      ? 'Enter BIB'
                      : selectedBib == null 
                          ? 'Enter BIB' 
                          : 'BIB: $selectedBib',
                  style: TextStyle(
                    color: isTemporary && selectedBib == null
                        ? Colors.orange
                        : selectedBib == null 
                            ? RaceColors.primary 
                            : RaceColors.black,
                    fontWeight: isTemporary && selectedBib == null 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios, size: 14, color: RaceColors.primary),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, size: RaceSpacings.s),
          onPressed: onReset,
          color: RaceColors.primary,
        ),
        const SizedBox(width: RaceSpacings.s),
      ],
      ),
    );
  }
}