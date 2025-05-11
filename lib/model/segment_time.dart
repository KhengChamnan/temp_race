class SegmentTime {
  final String participantBibNumber;
  final String segmentName; // "swim", "cycle", "run"
  final DateTime startTime;
  final DateTime? endTime;
  
  const SegmentTime({
    required this.participantBibNumber,
    required this.segmentName,
    required this.startTime,
    this.endTime,
  });
  
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }
  
  String get formattedDuration {
    final dur = duration;
    if (dur == null) return "--:--:--";
    
    final minutes = dur.inMinutes;
    final seconds = dur.inSeconds % 60;
    final milliseconds = dur.inMilliseconds % 1000;
    
    return "$minutes:${seconds.toString().padLeft(2, '0')}.${(milliseconds ~/ 10).toString().padLeft(2, '0')}";
  }
  
  bool get isCompleted => endTime != null;
  
  SegmentTime copyWith({
    String? participantBibNumber,
    String? segmentName,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return SegmentTime(
      participantBibNumber: participantBibNumber ?? this.participantBibNumber,
      segmentName: segmentName ?? this.segmentName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is SegmentTime &&
      other.participantBibNumber == participantBibNumber &&
      other.segmentName == segmentName &&
      other.startTime == startTime &&
      other.endTime == endTime;
  }

  @override
  int get hashCode {
    return participantBibNumber.hashCode ^
      segmentName.hashCode ^
      startTime.hashCode ^
      endTime.hashCode;
  }

  @override
  String toString() {
    return 'SegmentTime(participantBibNumber: $participantBibNumber, segmentName: $segmentName, startTime: $startTime, endTime: $endTime)';
  }
} 