import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Terms & Conditions',
          style: GoogleFonts.outfit(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Terms & Conditions',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Last updated: January 2026',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              _TermsSection(
                title: 'Acceptance of Terms',
                content:
                    'By creating an account and using PawPulse, you agree to these Terms & Conditions. If you do not agree, please do not use the app.',
              ),
              _TermsSection(
                title: 'Use of Service',
                content:
                    'PawPulse is designed to help pet owners manage their pets\' health and appointments at Vet District Animal Clinic. The app is intended for personal, non-commercial use only.',
              ),
              _TermsSection(
                title: 'Account Responsibilities',
                content:
                    'You are responsible for maintaining the confidentiality of your account credentials. You agree to provide accurate and complete information when creating your account and managing your pet profiles.',
              ),
              _TermsSection(
                title: 'Health Information Disclaimer',
                content:
                    'PawPulse is a pet care management tool and is not a substitute for professional veterinary advice. AI scan results are for informational purposes only and should not replace professional diagnosis from a licensed veterinarian.',
              ),
              _TermsSection(
                title: 'Appointment Policy',
                content:
                    'Appointments booked through PawPulse are subject to availability. Please cancel appointments at least 24 hours in advance. Repeated no-shows may result in account suspension.',
              ),
              _TermsSection(
                title: 'Limitation of Liability',
                content:
                    'PawPulse and Vet District Animal Clinic are not liable for any damages arising from the use or inability to use the app. We do not guarantee the accuracy of AI-generated health scan results.',
              ),
              _TermsSection(
                title: 'Changes to Terms',
                content:
                    'We reserve the right to modify these Terms & Conditions at any time. Continued use of the app after changes constitutes acceptance of the new terms.',
              ),
              _TermsSection(
                title: 'Contact Us',
                content:
                    'For questions about these Terms & Conditions, contact us at vetdistrictclinic@email.com',
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  final String title;
  final String content;

  const _TermsSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: AppTheme.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
