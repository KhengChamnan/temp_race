import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/theme/theme.dart';

class ParticipantButton extends StatelessWidget {
  final String id;
  final bool isActive;
  final String? timestamp;
  final Function() onTap;
  final bool isLoading;
  
  const ParticipantButton({
    Key? key,
    required this.id,
    required this.isActive,
    this.timestamp,
    required this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format ID with leading zeros
    final formattedId = id.padLeft(3, '0');
    
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? RaceColors.primary : RaceColors.secondary,
          borderRadius: BorderRadius.circular(RaceSpacings.radius),
        ),
        height: 60,
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formattedId,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: RaceTextStyles.title.fontSize,
                  color: isActive ? RaceColors.white : RaceColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    height: 12,
                    width: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isActive ? RaceColors.white : RaceColors.primary,
                    ),
                  ),
                )
              else if (isActive && timestamp != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    timestamp!,
                    style: TextStyle(
                      color: RaceColors.white,
                      fontSize: RaceTextStyles.body.fontSize,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}