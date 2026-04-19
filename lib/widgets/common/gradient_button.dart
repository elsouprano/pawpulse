import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: AppTheme.buttonRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.secondary.withOpacity(isDisabled ? 0.3 : 1.0),
            AppTheme.primary.withOpacity(isDisabled ? 0.5 : 1.0),
          ],
        ),
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppTheme.buttonRadius,
          onTap: isDisabled ? null : onPressed,
          splashColor: AppTheme.secondary.withOpacity(0.3),
          highlightColor: AppTheme.primaryDark.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppTheme.textPrimary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: AppTheme.background,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
