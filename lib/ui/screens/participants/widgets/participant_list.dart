import 'package:flutter/material.dart';
import 'package:race_traking_app/model/participant.dart';
import 'package:race_traking_app/ui/widgets/styled_text_field.dart';
import 'package:race_traking_app/utils/bib_number_generator.dart';

class ParticipantList extends StatefulWidget {
  final List<Participant> participants;
  final Function(Participant) onEdit;
  final Function(String) onDelete;
  final Function(Participant, String) onSave;
  final Function(Participant) onAdd;
  final Function()? onRequestRenumber;
  final bool autoRenumberOnDelete;

  const ParticipantList({
    Key? key,
    required this.participants,
    required this.onEdit,
    required this.onDelete,
    required this.onSave,
    required this.onAdd,
    this.onRequestRenumber,
    this.autoRenumberOnDelete = false,
  }) : super(key: key);

  @override
  State<ParticipantList> createState() => _ParticipantListState();
}

class _ParticipantListState extends State<ParticipantList> {
  String? editingBibNumber;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bibController = TextEditingController();
  final TextEditingController newNameController = TextEditingController();
  final TextEditingController newBibController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set the initial BIB number when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateNextBibNumber();
    });
  }

  void _updateNextBibNumber() {
    // Get the next available BIB number
    final nextBib = BibNumberGenerator.generateNextBibNumber(widget.participants);
    
    // Only update if the new BIB number is different from the current one
    // This prevents unnecessary text controller updates
    if (newBibController.text != nextBib) {
      newBibController.text = nextBib;
    }
  }

  // Handle deleting a participant, with optional auto-renumbering
  void _handleDeleteParticipant(String bibNumber) {
    // Delete participant - renumbering is now handled in the provider
    widget.onDelete(bibNumber);
  }

  @override
  void didUpdateWidget(ParticipantList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Always update the BIB number whenever the participants list changes
    // This handles additions, removals, and updates
    _updateNextBibNumber();
  }

  @override
  void dispose() {
    nameController.dispose();
    bibController.dispose();
    newNameController.dispose();
    newBibController.dispose();
    super.dispose();
  }

  void startEditing(Participant participant) {
    setState(() {
      editingBibNumber = participant.bibNumber;
      bibController.text = participant.bibNumber;
      nameController.text = '${participant.firstName} ${participant.lastName}'.trim();
    });
  }

  void cancelEditing() {
    setState(() {
      editingBibNumber = null;
      bibController.clear();
      nameController.clear();
    });
  }

  void saveParticipant() {
    if (editingBibNumber != null && 
        bibController.text.isNotEmpty && 
        nameController.text.isNotEmpty) {
      
      List<String> nameParts = nameController.text.split(' ');
      String firstName = nameParts.first;
      String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final updatedParticipant = Participant(
        bibNumber: bibController.text,
        firstName: firstName,
        lastName: lastName,
      );

      widget.onSave(updatedParticipant, editingBibNumber!);
      cancelEditing();
    }
  }

  void addNewParticipant() {
    if (newBibController.text.isNotEmpty && newNameController.text.isNotEmpty) {
      List<String> nameParts = newNameController.text.split(' ');
      String firstName = nameParts.first;
      String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final newParticipant = Participant(
        bibNumber: newBibController.text,
        firstName: firstName,
        lastName: lastName,
      );

      widget.onAdd(newParticipant);
      
      // Clear only the name field, not the BIB field
      newNameController.clear();
      
      // Wait briefly for the add operation to complete
      Future.delayed(const Duration(milliseconds: 300), () {
        // Generate the next BIB number
        _updateNextBibNumber();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.participants.length,
              itemBuilder: (context, index) {
                final participant = widget.participants[index];
                final isEditing = editingBibNumber == participant.bibNumber;
                
                if (isEditing) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        StyledTextField(
                          controller: bibController,
                          hintText: 'BIB',
                          flex: 2,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(width: 8),
                        StyledTextField(
                          controller: nameController,
                          hintText: 'Name',
                          flex: 5,
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: saveParticipant,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: cancelEditing,
                        ),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: () => startEditing(participant),
                      child: Row(
                        children: [
                          StyledDisplayField(
                            text: participant.bibNumber,
                            flex: 2,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(width: 8),
                          StyledDisplayField(
                            text: '${participant.firstName} ${participant.lastName}'.trim(),
                            flex: 5,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _handleDeleteParticipant(participant.bibNumber),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            // Add new participant form
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  StyledTextField(
                    controller: newBibController,
                    hintText: 'BIB',
                    flex: 2,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(width: 8),
                  StyledTextField(
                    controller: newNameController,
                    hintText: 'Name',
                    flex: 5,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green, size: 28),
                    onPressed: addNewParticipant,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}