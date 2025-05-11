import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:race_traking_app/model/segment_time.dart';
import 'package:race_traking_app/utils/timestamp_formatter.dart';

/// Utility class for two-step time tracking functionality
class TwoStepHelper {
  /// Extracts relevant segment times for the two-step view
  static List<SegmentTime> extractFinishTimes(
    List<SegmentTime> segmentTimes, 
    String segmentName
  ) {
    final normalizedSegmentName = segmentName.toLowerCase();
    
    // Filter segment times for the current segment and that have endTime (completed)
    final relevantTimes = segmentTimes
        .where((time) => 
            time.segmentName.toLowerCase() == normalizedSegmentName && 
            time.endTime != null)
        .toList();
    
    // Sort by end time (most recent first)
    relevantTimes.sort((a, b) => b.endTime!.compareTo(a.endTime!));
    
    return relevantTimes;
  }
  
  /// Assigns a BIB number to a finish time
  /// Returns a Future that completes when the assignment is done
  static Future<void> assignBibToFinishTime({
    required String segmentName,
    required DateTime finishTime,
    required String bibNumber,
    required Function(String, String, DateTime) assignBibCallback,
  }) async {
    // Call the assignBibToFinishTime function with the bibNumber, segmentName, and finishTime
    await assignBibCallback(bibNumber, segmentName, finishTime);
  }
  
  /// Formats time for display in the two-step list
  static String formatTimeForDisplay(DateTime time) {
    // Format in MM:SS.ms format for better readability and precision
    final minutes = time.minute.toString().padLeft(2, '0');
    final seconds = time.second.toString().padLeft(2, '0');
    final milliseconds = (time.millisecond ~/ 10).toString().padLeft(2, '0');
    
    return "$minutes:$seconds.$milliseconds";
  }
  
  /// Formats time with hours for more complete display
  static String formatDetailedTime(DateTime time) {
    return DateFormat('HH:mm:ss.SSS').format(time);
  }
  
  /// Checks if a BIB number is already assigned to a different finish time
  static bool isBibAlreadyAssigned(
    List<SegmentTime> finishTimes,
    Map<int, String> assignedBibs,
    String bibNumber
  ) {
    // Check in already known segment times
    final bibInFinishTimes = finishTimes.any((item) => item.participantBibNumber == bibNumber);
    
    // Check in currently assigned bibs
    final bibInAssignedBibs = assignedBibs.values.contains(bibNumber);
    
    return bibInFinishTimes || bibInAssignedBibs;
  }
} 