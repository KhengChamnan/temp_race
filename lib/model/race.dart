enum RaceStatus {
  notStarted,
  started,
  finished
}

class Race {
  final DateTime date;
  final RaceStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<String> participantBibNumbers; // References to participants
  final Map<String, double> segmentDistances; // segment name -> distance

  const Race({
    required this.date,
    this.status = RaceStatus.notStarted,
    this.startTime,
    this.endTime,
    this.participantBibNumbers = const [],
    this.segmentDistances = const {
      'swim': 1000, // meters
      'cycle': 20000, // meters (20km)
      'run': 5000, // meters (5km)
    },
  });

  Race copyWith({
    DateTime? date,
    RaceStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? participantBibNumbers,
    Map<String, double>? segmentDistances,
  }) {
    return Race(
      date: date ?? this.date,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      participantBibNumbers: participantBibNumbers ?? this.participantBibNumbers,
      segmentDistances: segmentDistances ?? this.segmentDistances,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Race &&
      other.date == date &&
      other.status == status &&
      other.startTime == startTime &&
      other.endTime == endTime &&
      other.participantBibNumbers.length == participantBibNumbers.length &&
      other.segmentDistances.length == segmentDistances.length;
  }

  @override
  int get hashCode {
    return date.hashCode ^
      status.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      participantBibNumbers.hashCode ^
      segmentDistances.hashCode;
  }

  @override
  String toString() {
    return 'Race(date: $date, status: $status, startTime: $startTime, endTime: $endTime, participantBibNumbers: $participantBibNumbers, segmentDistances: $segmentDistances)';
  }
} 