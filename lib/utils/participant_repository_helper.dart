import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:race_traking_app/data/dto/participant_dto.dart';
import 'package:race_traking_app/model/participant.dart';
import 'package:race_traking_app/utils/bib_number_generator.dart';

/// Utility class with helper functions for participant repositories
class ParticipantRepositoryHelper {
  
  /// Shifts BIB numbers up for participants when inserting a new participant with an existing BIB
  static void shiftBibNumbersUpForInsert(List<Participant> participants, String bibNumber) {
    // Sort participants by BIB number
    BibNumberGenerator.sortParticipantsByBib(participants);
    
    // Find index of the participant with the given BIB
    final insertionIndex = BibNumberGenerator.findParticipantIndexByBib(participants, bibNumber);
    if (insertionIndex == -1) return;
    
    // Shift BIBs up starting from the insertion point (in reverse order)
    for (int i = participants.length - 1; i >= insertionIndex; i--) {
      participants[i] = BibNumberGenerator.incrementBibNumber(participants[i]);
    }
  }

  /// Shifts BIB numbers down after deleting a participant
  static void shiftBibNumbersDownAfterDelete(List<Participant> participants, String bibNumber) {
    // Find the participant index
    final deleteIndex = BibNumberGenerator.findParticipantIndexByBib(participants, bibNumber);
    if (deleteIndex == -1) return;
    
    // Remove the participant
    participants.removeAt(deleteIndex);
    
    // Decrement BIB numbers for all participants after the deleted one
    for (int i = deleteIndex; i < participants.length; i++) {
      participants[i] = BibNumberGenerator.decrementBibNumber(participants[i]);
    }
  }

  /// Creates a Firestore batch for shifting BIB numbers up during insertion
  static WriteBatch createBibShiftUpBatch(
    FirebaseFirestore firestore,
    List<Participant> participants,
    String collectionPath,
    String bibNumber,
    Participant newParticipant
  ) {
    // Sort participants by BIB number
    BibNumberGenerator.sortParticipantsByBib(participants);
    
    // Find index of the existing BIB
    final existingIndex = BibNumberGenerator.findParticipantIndexByBib(participants, bibNumber);
    if (existingIndex == -1) return firestore.batch();
    
    // Create batch
    final batch = firestore.batch();
    
    // Shift BIBs up starting from the insertion point in a batch (in reverse order)
    for (int i = participants.length - 1; i >= existingIndex; i--) {
      final current = participants[i];
      final updatedParticipant = BibNumberGenerator.incrementBibNumber(current);
      
      // Add to batch
      batch.set(
        firestore.collection(collectionPath).doc(updatedParticipant.bibNumber),
        ParticipantDto.toJson(updatedParticipant)
      );
      
      // Delete old document
      if (i != existingIndex) { // Don't delete the doc we're about to replace
        batch.delete(firestore.collection(collectionPath).doc(current.bibNumber));
      }
    }
    
    // Add the new participant
    batch.set(
      firestore.collection(collectionPath).doc(newParticipant.bibNumber),
      ParticipantDto.toJson(newParticipant)
    );
    
    return batch;
  }

  /// Creates a Firestore batch for shifting BIB numbers down after deletion
  static WriteBatch createBibShiftDownBatch(
    FirebaseFirestore firestore, 
    List<Participant> participants, 
    String collectionPath, 
    String bibNumber
  ) {
    // Sort participants by BIB number
    BibNumberGenerator.sortParticipantsByBib(participants);
    
    // Find index of the participant to delete
    final deleteIndex = BibNumberGenerator.findParticipantIndexByBib(participants, bibNumber);
    if (deleteIndex == -1) {
      final batch = firestore.batch();
      batch.delete(firestore.collection(collectionPath).doc(bibNumber));
      return batch;
    }
    
    // Create batch
    final batch = firestore.batch();
    
    // Delete the participant
    batch.delete(firestore.collection(collectionPath).doc(bibNumber));
    
    // Shift BIBs down for participants after the deleted one
    for (int i = deleteIndex + 1; i < participants.length; i++) {
      final current = participants[i];
      final updatedParticipant = BibNumberGenerator.decrementBibNumber(current);
      
      // Add to batch: add new document with updated BIB
      batch.set(
        firestore.collection(collectionPath).doc(updatedParticipant.bibNumber),
        ParticipantDto.toJson(updatedParticipant)
      );
      
      // Delete old document
      batch.delete(firestore.collection(collectionPath).doc(current.bibNumber));
    }
    
    return batch;
  }
  
  /// Finds a participant by name (first and last name)
  static Participant? findParticipantByName(
    List<Participant> participants, 
    String firstName, 
    String lastName
  ) {
    try {
      return participants.firstWhere(
        (p) => p.firstName == firstName && p.lastName == lastName
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Creates a Firestore batch for updating a participant with a new BIB number
  static WriteBatch createBibUpdateBatch(
    FirebaseFirestore firestore,
    String collectionPath,
    String oldBibNumber,
    Participant updatedParticipant
  ) {
    final batch = firestore.batch();
    
    // Delete old document
    batch.delete(firestore.collection(collectionPath).doc(oldBibNumber));
    
    // Add new document with updated BIB
    batch.set(
      firestore.collection(collectionPath).doc(updatedParticipant.bibNumber),
      ParticipantDto.toJson(updatedParticipant)
    );
    
    return batch;
  }
} 