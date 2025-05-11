import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:race_traking_app/model/race.dart';

class RaceDto {

  static Race fromJson(String id, Map<String, dynamic> json) {
    try {
      // Safely extract the date with fallback to current date if missing or invalid
      DateTime date;
      try {
        date = (json['date'] as Timestamp).toDate();
      } catch (e) {
        date = DateTime.now();
      }
      
      // Safely extract status with fallback to notStarted if missing or invalid
      RaceStatus status;
      try {
        int statusIndex = json['status'] as int;
        status = RaceStatus.values[statusIndex];
      } catch (e) {
        status = RaceStatus.notStarted;
      }
      
      // Safely extract timestamps with proper null handling
      DateTime? startTime;
      if (json['startTime'] != null) {
        try {
          startTime = (json['startTime'] as Timestamp).toDate();
        } catch (e) {
          // Invalid timestamp, leave as null
        }
      }
      
      DateTime? endTime;
      if (json['endTime'] != null) {
        try {
          endTime = (json['endTime'] as Timestamp).toDate();
        } catch (e) {
          // Invalid timestamp, leave as null
        }
      }
      
      // Safely extract participant bib numbers with fallback to empty list
      List<String> participantBibNumbers;
      try {
        participantBibNumbers = List<String>.from(json['participantBibNumbers'] ?? []);
      } catch (e) {
        participantBibNumbers = [];
      }
      
      // Safely extract segment distances with fallback to default values
      Map<String, double> segmentDistances;
      try {
        segmentDistances = Map<String, double>.from(json['segmentDistances'] ?? {});
      } catch (e) {
        segmentDistances = {
          'swim': 1000.0,
          'cycle': 20000.0,
          'run': 5000.0,
        };
      }
      
      return Race(
        date: date,
        status: status,
        startTime: startTime,
        endTime: endTime,
        participantBibNumbers: participantBibNumbers,
        segmentDistances: segmentDistances,
      );
    } catch (e) {
      print("Error parsing race data: $e");
      // Return a default race if parsing fails completely
      return Race(
        date: DateTime.now(),
        status: RaceStatus.notStarted,
        participantBibNumbers: [],
      );
    }
  }

  static Map<String, dynamic> toJson(Race race) {
    return {
      'date': Timestamp.fromDate(race.date),
      'status': race.status.index,
      'startTime': race.startTime != null ? Timestamp.fromDate(race.startTime!) : null,
      'endTime': race.endTime != null ? Timestamp.fromDate(race.endTime!) : null,
      'participantBibNumbers': race.participantBibNumbers,
      'segmentDistances': race.segmentDistances,
    };
  }
  
}