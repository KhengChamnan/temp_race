// The ResultListTile component
import 'package:flutter/material.dart';
import 'package:race_traking_app/model/race_result_board.dart';
import 'package:race_traking_app/ui/screens/resultBoard/widget/edit_dialog.dart';

import 'package:race_traking_app/ui/theme/theme.dart';
import 'package:race_traking_app/ui/widgets/dataRow.dart';

class ResultListTile extends StatelessWidget {
  final RaceResultItem result;
  final bool isEven;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ResultListTile({
    Key? key,
    required this.result,
    this.isEven = false,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

 void showEditDialog(BuildContext context, RaceResultItem result) {
    showDialog(
      context: context,
      builder: (context) => EditResultDialog(
        result: result,
        onSave: (updatedResult) {

          Navigator.of(context).pop();
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      //when the user taps on the tile, show the edit dialog
      onTap: () => showEditDialog(context, result),
      //when the user long presses on the tile, show the delete confirmation dialog
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Result'),
              content: Text(
                  'Are you sure you want to delete ${result.participantName}\'s result?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: RaceColors.red,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onDelete != null) onDelete!();
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        width: 1000,
        color: isEven ? RaceColors.secondary : RaceColors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              DataInRow(text: result.rank.toString(), flex: 1),
              DataInRow(text: result.bibNumber, flex: 1),
              DataInRow(text: result.participantName, flex: 2),
              DataInRow(
                  text: result.getSegmentTime('cycle')?.formattedDuration ??
                      '--:--:--',
                  flex: 1),
              DataInRow(
                  text: result.getSegmentTime('run')?.formattedDuration ??
                      '--:--:--',
                  flex: 1),
              DataInRow(
                  text: result.getSegmentTime('swim')?.formattedDuration ??
                      '--:--:--',
                  flex: 1),
              DataInRow(text: result.formattedTotalDuration, flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}