import 'package:flutter/material.dart';

/// Utility class for timestamp related operations
class TimestampFormatter {
  /// Formats a timestamp to display in HH:MM:SS format
  static String formatTimestamp(DateTime timestamp) {
    return timestamp.toIso8601String().substring(11, 19);
  }

  /// Formats a timestamp from a segmentTime object
  static String? getTimestampFromSegment(dynamic segmentTime) {
    if (segmentTime == null) return null;

    if (segmentTime.endTime != null) {
      // Format the end time without milliseconds
      final endTime = segmentTime.endTime!;
      return formatTimestamp(endTime);
    } else if (segmentTime.startTime != null) {
      // For active segment, show the starting time
      final startTime = segmentTime.startTime;
      return formatTimestamp(startTime);
    }

    return null;
  }

  /// Creates a DateTime from a time string in format "HH:MM:SS"
  static DateTime createDateTimeFromTimeString(String timeString) {
    final timeParts = timeString.split(':');
    
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    // Handle seconds that might contain milliseconds
    final secondsParts = timeParts[2].split('.');
    final second = int.parse(secondsParts[0]);
    
    // Create the timestamp using current date
    final now = DateTime.now();
    return DateTime(
      now.year, now.month, now.day, hour, minute, second
    );
  }

  /// Add method to parse timestamp string back to DateTime
  static DateTime? parseTimestamp(String timeString) {
    try {
      // Format expected: "HH:MM:SS"
      final parts = timeString.split(':');
      if (parts.length != 3) return null;
      
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final seconds = int.parse(parts[2]);
      
      // Create DateTime with current date but with the specified time
      final now = DateTime.now();
      return DateTime(
        now.year, 
        now.month, 
        now.day, 
        hours, 
        minutes, 
        seconds
      );
    } catch (e) {
      return null;
    }
  }
} 