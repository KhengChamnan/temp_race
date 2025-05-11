import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:race_traking_app/data/dto/race_dto.dart';
import 'package:race_traking_app/data/dto/segment_time_dto.dart';
import 'package:race_traking_app/model/race.dart';
import 'package:race_traking_app/model/race_result_board.dart';
import 'package:race_traking_app/model/segment_time.dart';

class RaceResultBoardDto {
  
  static RaceResultBoard fromJson(String id, Map<String, dynamic> json) {
    try {
      // Parse race data
      final raceData = json['race'] as Map<String, dynamic>;
      final race = RaceDto.fromJson(id, raceData);
      
      // Parse result items
      final List<dynamic> resultItemsData = json['resultItems'] ?? [];
      final List<RaceResultItem> resultItems = resultItemsData
          .map((itemData) => _resultItemFromJson(itemData as Map<String, dynamic>))
          .toList();
      
      return RaceResultBoard(
        race: race,
        resultItems: resultItems,
      );
    } catch (e) {
      print("Error parsing race result board data: $e");
      // Return a default board if parsing fails completely
      return RaceResultBoard(
        race: Race(date: DateTime.now()),
        resultItems: [],
      );
    }
  }
  
  static Map<String, dynamic> toJson(RaceResultBoard board) {
    return {
      'race': RaceDto.toJson(board.race),
      'resultItems': board.resultItems.map(_resultItemToJson).toList(),
      'lastUpdated': Timestamp.now(),
    };
  }
  
  static RaceResultItem _resultItemFromJson(Map<String, dynamic> json) {
    final String bibNumber = json['bibNumber'] ?? '';
    final String participantName = json['participantName'] ?? '';
    final int rank = json['rank'] ?? 0;
    
    // Parse segment times
    final Map<String, dynamic> segmentTimesJson = json['segmentTimes'] ?? {};
    final Map<String, SegmentTime> segmentTimes = {};
    
    segmentTimesJson.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final segmentTime = SegmentTimeDto.fromJson('', value);
        segmentTimes[key] = segmentTime;
      }
    });
    
    // Parse total duration
    Duration? totalDuration;
    if (json['totalDuration'] != null) {
      try {
        totalDuration = Duration(milliseconds: json['totalDuration']);
      } catch (e) {
        // Invalid duration, leave as null
      }
    }
    
    return RaceResultItem(
      bibNumber: bibNumber,
      participantName: participantName,
      segmentTimes: segmentTimes,
      totalDuration: totalDuration,
      rank: rank,
    );
  }
  
  static Map<String, dynamic> _resultItemToJson(RaceResultItem item) {
    final Map<String, dynamic> segmentTimesJson = {};
    
    item.segmentTimes.forEach((key, value) {
      segmentTimesJson[key] = SegmentTimeDto.toJson(value);
    });
    
    return {
      'bibNumber': item.bibNumber,
      'participantName': item.participantName,
      'rank': item.rank,
      'totalDuration': item.totalDuration?.inMilliseconds,
      'segmentTimes': segmentTimesJson,
    };
  }
} 