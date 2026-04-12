import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SuccessCard extends StatelessWidget {
  final String message;

  const SuccessCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.08),
        border: Border.all(color: AppTheme.accent, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppTheme.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppTheme.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
