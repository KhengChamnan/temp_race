import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/theme/theme.dart';

class ParticipantForm extends StatelessWidget {
  final bool isEditing;
  final TextEditingController bibController;
  final TextEditingController nameController;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const ParticipantForm({
    Key? key,
    required this.isEditing,
    required this.bibController,
    required this.nameController,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: RaceColors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextField(
              controller: bibController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                border: InputBorder.none,
                hintText: 'BIB',
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: RaceColors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                border: InputBorder.none,
                hintText: 'Name',
              ),
            ),
          ),
        ),
        isEditing
            ? Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: onSave,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: onCancel,
                  ),
                ],
              )
            : IconButton(
                icon: const Icon(Icons.add, color: RaceColors.primary),
                onPressed: onSave,
              ),
      ],
    );
  }
}