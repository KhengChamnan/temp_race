import 'package:race_traking_app/model/participant.dart';
import 'package:race_traking_app/model/race.dart';
import 'package:race_traking_app/model/segment_time.dart';

class RaceResultItem {
  final String bibNumber;
  final String participantName;
  final Map<String, SegmentTime> segmentTimes;
  final Duration? totalDuration;
  final int rank;

  RaceResultItem({
    required this.bibNumber,
    required this.participantName,
    required this.segmentTimes,
    this.totalDuration,
    required this.rank,
  });

  SegmentTime? getSegmentTime(String segmentName) {
    return segmentTimes[segmentName];
  }

  String get formattedTotalDuration {
    if (totalDuration == null) return "--:--:--";
    
    final hours = totalDuration!.inHours;
    final minutes = (totalDuration!.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (totalDuration!.inSeconds % 60).toString().padLeft(2, '0');
    final milliseconds = (totalDuration!.inMilliseconds % 1000 ~/ 10).toString().padLeft(2, '0');
    
    return "$hours:$minutes:$seconds.$milliseconds";
  }
}

class RaceResultBoard {
  final Race race;
  final List<RaceResultItem> resultItems;

  RaceResultBoard({
    required this.race,
    required this.resultItems,
  });

  static RaceResultBoard createFromData({
    required Race race,
    required List<Participant> participants,
    required List<SegmentTime> segmentTimes,
  }) {
    final Map<String, Map<String, SegmentTime>> segmentTimesByParticipant = {};
    
    for (final bibNumber in race.participantBibNumbers) {
      segmentTimesByParticipant[bibNumber] = {};
    }
    
    for (final time in segmentTimes) {
      if (segmentTimesByParticipant.containsKey(time.participantBibNumber)) {
        segmentTimesByParticipant[time.participantBibNumber]![time.segmentName] = time;
      }
    }
    
    List<RaceResultItem> items = [];
    
    for (final participant in participants) {
      if (!race.participantBibNumbers.contains(participant.bibNumber)) {
        continue;
      }
      
      final segmentTimesForParticipant = segmentTimesByParticipant[participant.bibNumber] ?? {};
      
      Duration? totalDuration;
      if (segmentTimesForParticipant.isNotEmpty) {
        final durations = segmentTimesForParticipant.values
            .map((time) => time.duration)
            .whereType<Duration>();
            
        if (durations.isNotEmpty) {
          totalDuration = durations.reduce((a, b) => a + b);
        }
      }
      
      items.add(RaceResultItem(
        bibNumber: participant.bibNumber,
        participantName: "${participant.firstName} ${participant.lastName}",
        segmentTimes: segmentTimesForParticipant,
        totalDuration: totalDuration,
        rank: 0,
      ));
    }
    
    items.sort((a, b) {
      if (a.totalDuration == null && b.totalDuration == null) return 0;
      if (a.totalDuration == null) return 1;
      if (b.totalDuration == null) return -1;
      return a.totalDuration!.compareTo(b.totalDuration!);
    });
    
    for (int i = 0; i < items.length; i++) {
      if (items[i].totalDuration != null) {
        items[i] = RaceResultItem(
          bibNumber: items[i].bibNumber,
          participantName: items[i].participantName,
          segmentTimes: items[i].segmentTimes,
          totalDuration: items[i].totalDuration,
          rank: i + 1,
        );
      }
    }
    
    return RaceResultBoard(
      race: race,
      resultItems: items,
    );
  }
} 