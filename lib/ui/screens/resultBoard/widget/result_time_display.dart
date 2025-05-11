import 'package:flutter/material.dart';
import 'package:race_traking_app/model/race_result_board.dart';
import 'package:race_traking_app/ui/theme/theme.dart';

class ResultTimeDisplay extends StatelessWidget {
  final RaceResultItem result;
  final bool isEven;

  const ResultTimeDisplay({
    Key? key,
    required this.result,
    required this.isEven,
  }) : super(key: key);

  String formatTime(String segmentName) {
    final segmentTime = result.getSegmentTime(segmentName);
    return segmentTime?.formattedDuration ?? '--:--:--';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isEven ? RaceColors.secondary : RaceColors.white,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Text('Run Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(formatTime('run'), textAlign: TextAlign.center),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Text('Swim Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(formatTime('swim'), textAlign: TextAlign.center),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Text('Total Duration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(result.formattedTotalDuration, textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 