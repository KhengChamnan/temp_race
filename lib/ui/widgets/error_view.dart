import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/theme/theme.dart';

/// A reusable error view widget with retry functionality
class ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final String retryText;

  const ErrorView({
    Key? key,
    required this.error,
    required this.onRetry,
    this.retryText = 'Retry',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'An error occurred',
              style: RaceTextStyles.title.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: RaceTextStyles.body,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: RaceColors.primary,
                foregroundColor: RaceColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(retryText),
            ),
          ],
        ),
      ),
    );
  }
} 