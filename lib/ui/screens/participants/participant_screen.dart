import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_traking_app/model/participant.dart';
import 'package:race_traking_app/ui/providers/participant_provider.dart';
import 'package:race_traking_app/ui/screens/participants/widgets/participant_header.dart';
import 'package:race_traking_app/ui/screens/participants/widgets/participant_list.dart';
import 'package:race_traking_app/ui/theme/theme.dart';
import 'package:race_traking_app/ui/widgets/navBar.dart';

class ParticipantScreen extends StatefulWidget {
  const ParticipantScreen({Key? key}) : super(key: key);

  @override
  State<ParticipantScreen> createState() => _ParticipantScreenState();
}

class _ParticipantScreenState extends State<ParticipantScreen> {
  final TextEditingController _bibController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _bibController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _updateParticipant(Participant updatedParticipant, String originalBibNumber, ParticipantProvider provider) {
    provider.updateParticipant(updatedParticipant);
  }

  void _deleteParticipant(String bibNumber, ParticipantProvider provider) {
    provider.deleteParticipant(bibNumber);
  }
  


  @override
  Widget build(BuildContext context) {
    final participantProvider = Provider.of<ParticipantProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const ParticipantHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Participant List',
                    style: RaceTextStyles.subtitle
                        .copyWith(fontFamily: 'YourFontFamily'),
                  ),
                  const SizedBox(height: 16),
                  _buildParticipantListWidget(participantProvider),
                ],
              ),
            ),
          ),
          const Navbar(selectedIndex: 0),
        ],
      ),
    );
  }

  Widget _buildParticipantListWidget(ParticipantProvider provider) {
    if (provider.participantsValue.isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (provider.participantsValue.isError) {
      return Expanded(
        child: Center(
          child: Text('Error loading participants: ${provider.participantsValue.error}'),
        ),
      );
    } else if (provider.participantsValue.isSuccess && 
               provider.participantsValue.data != null) {
      final participants = provider.participantsValue.data!;
      
      return Expanded(
        child: ParticipantList(
          participants: participants,
          onEdit: (_) {}, 
          onDelete: (bibNumber) => _deleteParticipant(bibNumber, provider),
          onSave: (participant, originalBib) => _updateParticipant(participant, originalBib, provider),
          onAdd: (participant) => provider.addParticipant(participant),
          autoRenumberOnDelete: true, 
        ),
      );
    } else {
      return const Expanded(
        child: Center(child: Text('Something went wrong')),
      );
    }
  }
}