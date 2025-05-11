import 'package:race_traking_app/model/participant.dart';

/// Utility class to generate sequential BIB numbers.
class BibNumberGenerator {
  /// Generates the next available BIB number based on existing participants
  /// 
  /// Format: 001, 002, 003, ... etc.
  /// If the list is empty, starts with "001"
  /// If a gap is found in the sequence (e.g., after deleting), it will use the lowest available number
  static String generateNextBibNumber(List<Participant> participants) {
    if (participants.isEmpty) {
      return "001"; // Start with 001 if no participants
    }

    // Extract all numeric BIB values and sort them
    final List<int> bibValues = [];
    for (final participant in participants) {
      final bibText = participant.bibNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final bibValue = int.tryParse(bibText) ?? 0;
      bibValues.add(bibValue);
    }
    bibValues.sort();

    // Find the first gap or return the next number after the highest
    int nextBib = 1; // Start checking from 1
    for (final value in bibValues) {
      if (value != nextBib) {
        break; // Found a gap
      }
      nextBib++;
    }

    // Format with leading zeros (e.g., 001, 002, etc.)
    return nextBib.toString().padLeft(3, '0');
  }

  /// Generates a sequential range of BIB numbers based on the count requested
  /// 
  /// Format: 001, 002, 003, ... etc.
  /// If startFromExisting is true, it will find the next available number after existing participants
  static List<String> generateBibNumberBatch(
    int count, {
    List<Participant> existingParticipants = const [],
    bool startFromExisting = true,
  }) {
    int startNumber = 1;

    if (startFromExisting && existingParticipants.isNotEmpty) {
      // Extract the maximum existing BIB number
      final bibNumbers = existingParticipants
        .map((p) => p.bibNumber)
        .where((bib) => RegExp(r'^\d+$').hasMatch(bib))
        .map((bib) => int.tryParse(bib) ?? 0)
        .toList();

      if (bibNumbers.isNotEmpty) {
        startNumber = bibNumbers.reduce((a, b) => a > b ? a : b) + 1;
      }
    }

    // Generate the batch of BIB numbers
    return List.generate(
      count,
      (index) => (startNumber + index).toString().padLeft(3, '0'),
    );
  }
  
  /// Sort participants by their BIB number in ascending order.
  /// 
  /// This handles extracting numeric parts from BIB numbers and sorting them properly.
  static void sortParticipantsByBib(List<Participant> participants) {
    participants.sort((a, b) {
      final aNum = int.tryParse(a.bibNumber.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final bNum = int.tryParse(b.bibNumber.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return aNum.compareTo(bNum);
    });
  }
  
  /// Extracts the numeric value from a BIB number string.
  /// 
  /// For example: "001" becomes 1, "A123" becomes 123
  static int extractNumericBibValue(String bibNumber) {
    return int.tryParse(bibNumber.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }
  
  /// Creates a new participant with an incremented BIB number.
  /// 
  /// Used when shifting BIB numbers up (for insertion).
  static Participant incrementBibNumber(Participant participant) {
    final currentNum = extractNumericBibValue(participant.bibNumber);
    final newBib = (currentNum + 1).toString().padLeft(3, '0');
    
    return Participant(
      bibNumber: newBib,
      firstName: participant.firstName,
      lastName: participant.lastName,
      age: participant.age,
      gender: participant.gender,
    );
  }
  
  /// Creates a new participant with a decremented BIB number.
  /// 
  /// Used when shifting BIB numbers down (for deletion).
  static Participant decrementBibNumber(Participant participant) {
    final currentNum = extractNumericBibValue(participant.bibNumber);
    final newBib = (currentNum - 1).toString().padLeft(3, '0');
    
    return Participant(
      bibNumber: newBib,
      firstName: participant.firstName,
      lastName: participant.lastName,
      age: participant.age,
      gender: participant.gender,
    );
  }
  
  /// Finds the index of a participant with the given BIB number in a sorted list.
  static int findParticipantIndexByBib(List<Participant> sortedParticipants, String bibNumber) {
    return sortedParticipants.indexWhere((p) => p.bibNumber == bibNumber);
  }
} 