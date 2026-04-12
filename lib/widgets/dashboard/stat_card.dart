import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool? trendUp;
  final String? trendLabel;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trendUp,
    this.trendLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                if (trendLabel != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        trendUp == true ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: trendUp == true ? const Color(0xFF00D4AA) : const Color(0xFFFF6B6B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trendLabel!,
                        style: TextStyle(
                          fontSize: 11,
                          color: trendUp == true ? const Color(0xFF00D4AA) : const Color(0xFFFF6B6B),
                        ),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.primary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
