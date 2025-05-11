import 'package:flutter/material.dart';
import 'package:race_traking_app/model/race_result_board.dart';
import 'package:race_traking_app/ui/theme/theme.dart';

class EditResultDialog extends StatelessWidget {
  final RaceResultItem result;
  final Function(RaceResultItem) onSave;
  final VoidCallback onCancel;

  const EditResultDialog({
    Key? key,
    required this.result,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  Widget EditField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RaceSpacings.radius),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: RaceColors.primary, width: 2.0),
            borderRadius: BorderRadius.circular(RaceSpacings.radius),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: RaceColors.darkGrey, width: 1.0),
            borderRadius: BorderRadius.circular(RaceSpacings.radius),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: RaceColors.red, width: 1.0),
            borderRadius: BorderRadius.circular(RaceSpacings.radius),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: RaceColors.red, width: 2.0),
            borderRadius: BorderRadius.circular(RaceSpacings.radius),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bibController = TextEditingController(text: result.bibNumber);
    final nameController = TextEditingController(text: result.participantName);
    final cycleController = TextEditingController(
      text: result.getSegmentTime('Cycle')?.formattedDuration ?? '--:--:--:--'
    );
    final runController = TextEditingController(
      text: result.getSegmentTime('Run')?.formattedDuration ?? '--:--:--:--'
    );
    final swimController = TextEditingController(
      text: result.getSegmentTime('Swim')?.formattedDuration ?? '--:--:--:--'
    );

    return AlertDialog(
      title: Text('Edit Result - ${result.participantName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EditField('BIB', bibController),
            EditField('Name', nameController),
            EditField('Cycle Time', cycleController),
            EditField('Run Time', runController),
            EditField('Swim Time', swimController),
            const SizedBox(height: 8),
            Text(
              'Total Duration: ${result.formattedTotalDuration}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: RaceColors.primary,
          ),
          onPressed: () {
            // Create updated result with new values
            final updatedResult = RaceResultItem(
              bibNumber: bibController.text,
              participantName: nameController.text,
              segmentTimes: result.segmentTimes,
              totalDuration: result.totalDuration,
              rank: result.rank,
            );
            onSave(updatedResult);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }


}