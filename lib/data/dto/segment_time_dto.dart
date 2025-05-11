import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:race_traking_app/model/segment_time.dart';

class SegmentTimeDto {

  static SegmentTime fromJson(String id, Map<String, dynamic> json) {
    try {
      // Safely extract timestamps with proper null handling
      DateTime startTime;
      try {
        startTime = (json['startTime'] as Timestamp).toDate();
      } catch (e) {
        startTime = DateTime.now();
      }
      
      DateTime? endTime;
      if (json['endTime'] != null) {
        try {
          endTime = (json['endTime'] as Timestamp).toDate();
        } catch (e) {
          // Invalid timestamp, leave as null
        }
      }
      
      return SegmentTime(
        participantBibNumber: json['participantBibNumber'] ?? '',
        segmentName: json['segmentName'] ?? '',
        startTime: startTime,
        endTime: endTime,
      );
    } catch (e) {
      print("Error parsing segment time data: $e");
      // Return a default segment time if parsing fails completely
      return SegmentTime(
        participantBibNumber: '',
        segmentName: '',
        startTime: DateTime.now(),
      );
    }
  }

  static Map<String, dynamic> toJson(SegmentTime segmentTime) {
    return {
      'participantBibNumber': segmentTime.participantBibNumber,
      'segmentName': segmentTime.segmentName,
      'startTime': Timestamp.fromDate(segmentTime.startTime),
      'endTime': segmentTime.endTime != null ? Timestamp.fromDate(segmentTime.endTime!) : null,
    };
  }
  
} 