import 'package:flutter/foundation.dart';
import 'package:race_traking_app/data/repository/participant_repository.dart';
import 'package:race_traking_app/data/repository/mock/mock_participant_repository.dart';
import 'package:race_traking_app/model/participant.dart';
import 'package:race_traking_app/ui/providers/async_value.dart';

/// ParticipantProvider manages participant data and provides:
/// - Fetching and caching of all participants
/// - Single participant retrieval by bib number
/// - CRUD operations (create, read, update, delete)
/// - Optimistic UI updates for better user experience
/// - Automatic data synchronization with the repository
class ParticipantProvider extends ChangeNotifier {
  final ParticipantRepository _repository;
  final bool _isMockRepository;
  
  // AsyncValue for a list of participants
  AsyncValue<List<Participant>> participantsValue = const AsyncValue.loading();
  
  // AsyncValue for a single participant
  AsyncValue<Participant>? participantValue;
  
  // Local cache of participants for optimistic updates
  List<Participant> _cachedParticipants = [];      // Stores local copy for optimistic UI
  bool _hasLoadedInitialData = false;              // Tracks if we've loaded data at least once
  
  // Stream subscription for participants
  dynamic _participantsSubscription;

  /// Creates a new ParticipantProvider with the given repository.
  /// Automatically initializes data based on repository type.
  ParticipantProvider(this._repository)
    : _isMockRepository = _repository is MockParticipantRepository {
    // Initialize the provider 
    if (_isMockRepository) {
      // For mock repository, just fetch data directly
      fetchParticipants();
    } else {
      // For real repositories, subscribe to stream
      subscribeToParticipants();
    }
  }

  @override
  void dispose() {
    // Cancel any active stream subscriptions
    if (_participantsSubscription != null) {
      _participantsSubscription.cancel();
    }
    super.dispose();
  }

  /// Subscribes to the participant stream from the repository
  /// to keep the provider updated with the latest data.
  void subscribeToParticipants() {
    if (!_hasLoadedInitialData) {
      // 1 - Set loading state if this is the first data load
      participantsValue = const AsyncValue.loading();
      notifyListeners();
    }

    try {
      // 2 - Subscribe to the participants stream
      _participantsSubscription = _repository.getParticipantsStream().listen(
        (participants) {
          // 3 - Update cache and state with new data
          _cachedParticipants = List.from(participants);
          _hasLoadedInitialData = true;
          participantsValue = AsyncValue.success(participants);
          notifyListeners();
        },
        onError: (error) {
          // 4 - On error, use cached data if available
          if (_hasLoadedInitialData && _cachedParticipants.isNotEmpty) {
            participantsValue = AsyncValue.success(_cachedParticipants);
          } else {
            participantsValue = AsyncValue.error(error);
          }
          notifyListeners();
        }
      );
    } catch (error) {
      // 5 - Handle subscription setup errors
      if (_hasLoadedInitialData && _cachedParticipants.isNotEmpty) {
        participantsValue = AsyncValue.success(_cachedParticipants);
      } else {
        participantsValue = AsyncValue.error(error);
      }
      notifyListeners();
    }
  }

  /// Fetches all participants once without subscribing.
  /// Used primarily for mock repositories or one-time updates.
  Future<void> fetchParticipants() async {
    try {
      // 1 - Get participants from repository
      final participants = await _repository.getAllParticipants();
      
      // 2 - Update local cache and state
      _cachedParticipants = List.from(participants);
      _hasLoadedInitialData = true;
      participantsValue = AsyncValue.success(participants);
    } catch (error) {
      // 3 - On error, use cached data if available
      if (_hasLoadedInitialData && _cachedParticipants.isNotEmpty) {
        participantsValue = AsyncValue.success(_cachedParticipants);
      } else {
        participantsValue = AsyncValue.error(error);
      }
    }
    notifyListeners();
  }

  /// Subscribes to updates for a specific participant by bib number.
  /// Updates participantValue with loading, success, or error states.
  Future<void> subscribeToParticipantByBib(String bibNumber) async {
    // 1 - Set loading state and notify
    participantValue = const AsyncValue.loading();
    notifyListeners();

    try {
      // 2 - Fetch participant data
      final participant = await _repository.getParticipantByBib(bibNumber);
      
      // 3 - Update state with success
      participantValue = AsyncValue.success(participant);
      notifyListeners();
    } catch (error) {
      // 4 - Handle errors
      participantValue = AsyncValue.error(error);
      notifyListeners();
    }
  }

  /// Fetches a single participant by bib number without subscribing.
  Future<void> fetchParticipantByBib(String bibNumber) async {
    // 1 - Set loading state
    participantValue = const AsyncValue.loading();
    notifyListeners();

    try {
      // 2 - Fetch participant data
      final participant = await _repository.getParticipantByBib(bibNumber);
      
      // 3 - Update state with success
      participantValue = AsyncValue.success(participant);
    } catch (error) {
      // 4 - Handle errors
      participantValue = AsyncValue.error(error);
    }

    notifyListeners();
  }

  /// Adds a new participant with optimistic UI updates.
  /// Updates local cache immediately, then syncs with repository.
  Future<void> addParticipant(Participant participant) async {
    try {
      // 1 - Optimistic UI update
      if (participantsValue.isSuccess) {
        final updatedList = List<Participant>.from(_cachedParticipants);
        updatedList.add(participant);
        _cachedParticipants = updatedList;
        participantsValue = AsyncValue.success(updatedList);
        notifyListeners();
      }
      
      // 2 - Update repository (may take time)
      await _repository.addParticipant(participant);
      
      // 3 - For mock repositories, refresh data to get any auto-generated values
      if (_isMockRepository) {
        await fetchParticipants();
      }
    } catch (error) {
      // 4 - On error, revert to cached state if available
      if (_hasLoadedInitialData) {
        participantsValue = AsyncValue.success(_cachedParticipants);
      } else {
        participantsValue = AsyncValue.error(error);
      }
      notifyListeners();
    }
  }

  /// Updates an existing participant with optimistic UI updates.
  /// Updates local cache immediately, then syncs with repository.
  Future<void> updateParticipant(Participant participant) async {
    try {
      // 1 - Optimistic UI update
      if (participantsValue.isSuccess) {
        final updatedList = List<Participant>.from(_cachedParticipants);
        final index = updatedList.indexWhere((p) => p.bibNumber == participant.bibNumber);
        
        if (index >= 0) {
          // Update existing participant
          updatedList[index] = participant;
        } else {
          // If we're updating a BIB number, remove the old entry and add the new one
          updatedList.removeWhere((p) => 
            p.firstName == participant.firstName && 
            p.lastName == participant.lastName);
          updatedList.add(participant);
        }
        
        // 2 - Update cached list and state
        _cachedParticipants = updatedList;
        participantsValue = AsyncValue.success(updatedList);
        
        // 3 - Update single participant value if currently viewing this participant
        if (participantValue != null && 
            participantValue!.isSuccess && 
            participantValue!.data!.bibNumber == participant.bibNumber) {
          participantValue = AsyncValue.success(participant);
        }
        
        notifyListeners();
      }
      
      // 4 - Update the repository (may take time)
      await _repository.updateParticipant(participant);
      
      // 5 - For mock repositories, refresh data
      if (_isMockRepository) {
        await fetchParticipants();
      }
    } catch (error) {
      // 6 - On error, revert to cached state if available
      if (_hasLoadedInitialData) {
        participantsValue = AsyncValue.success(_cachedParticipants);
      } else {
        participantsValue = AsyncValue.error(error);
      }
      notifyListeners();
    }
  }

  /// Deletes a participant by bib number with optimistic UI updates.
  /// Removes from local cache immediately, then syncs with repository.
  Future<void> deleteParticipant(String bibNumber) async {
    // Store a copy of the current participants list for rollback in case of errors
    final List<Participant> previousList = List<Participant>.from(_cachedParticipants);
    
    try {
      // 1 - Optimistic UI update
      if (participantsValue.isSuccess) {
        final updatedList = List<Participant>.from(_cachedParticipants);
        updatedList.removeWhere((p) => p.bibNumber == bibNumber);
        _cachedParticipants = updatedList;
        participantsValue = AsyncValue.success(updatedList);
        
        // 2 - If viewing the deleted participant, clear it
        if (participantValue != null && 
            participantValue!.isSuccess && 
            participantValue!.data!.bibNumber == bibNumber) {
          participantValue = null;
        }
        
        notifyListeners();
      }
      
      // 3 - Update the repository (may take time)
      await _repository.deleteParticipant(bibNumber);
      
      // 4 - For mock repositories, refresh the data
      if (_isMockRepository) {
        await fetchParticipants();
      }
    } catch (error) {
      // 5 - On error, revert to previous state
      if (_hasLoadedInitialData) {
        _cachedParticipants = previousList;
        participantsValue = AsyncValue.success(previousList);
      } else {
        participantsValue = AsyncValue.error(error);
      }
      notifyListeners();
    }
  }

  /// Renumbers all participants in sequential order (001, 002, etc.)
  /// Updates all bib numbers in both UI and repository.
  Future<void> renumberParticipants() async {
    if (!participantsValue.isSuccess) return;
    
    // Store a copy of the current list in case we need to revert
    final previousList = List<Participant>.from(_cachedParticipants);
    
    try {
      // 1 - Get current participants
      final participants = List<Participant>.from(_cachedParticipants);
      
      // Skip if no participants
      if (participants.isEmpty) return;
      
      // 2 - Sort by numeric BIB value
      participants.sort((a, b) {
        final aNum = int.tryParse(a.bibNumber.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final bNum = int.tryParse(b.bibNumber.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return aNum.compareTo(bNum);
      });
      
      // 3 - Prepare for batch updates
      final updates = <Future<void>>[];
      final updatedParticipants = <Participant>[];
      
      // 4 - Assign sequential BIB numbers (001, 002, etc.)
      for (int i = 0; i < participants.length; i++) {
        final newBibNumber = (i + 1).toString().padLeft(3, '0');
        final participant = participants[i];
        
        // Create updated participant with all fields
        final updatedParticipant = Participant(
          bibNumber: newBibNumber,
          firstName: participant.firstName,
          lastName: participant.lastName,
          age: participant.age,
          gender: participant.gender,
        );
        
        // Only update if the BIB number needs to change
        if (participant.bibNumber != newBibNumber) {
          // Add to the list of update operations
          updates.add(_repository.updateParticipant(updatedParticipant));
        }
        
        updatedParticipants.add(updatedParticipant);
      }
      
      // 5 - Update the local state immediately (optimistic UI)
      _cachedParticipants = updatedParticipants;
      participantsValue = AsyncValue.success(updatedParticipants);
      notifyListeners();
        
      // 6 - Perform repository updates in the background
      if (updates.isNotEmpty) {
        await Future.wait(updates);
        
        // 7 - For mock repositories, refresh the updated data
        if (_isMockRepository) {
          await fetchParticipants();
        }
      }
    } catch (error) {
      // 8 - On error, revert to previous state
      _cachedParticipants = previousList;
      participantsValue = AsyncValue.success(previousList);
      notifyListeners();
    }
  }
}
