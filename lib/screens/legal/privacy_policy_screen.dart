import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
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
                'Privacy Policy',
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

              _PolicySection(
                title: 'Information We Collect',
                content:
                    'We collect information you provide when creating an account, including your name, email address, and phone number. We also collect information about your pets including their name, species, breed, age, weight, and health records.',
              ),
              _PolicySection(
                title: 'How We Use Your Information',
                content:
                    'Your information is used to provide and improve PawPulse services, manage your pet profiles and health records, send appointment reminders and vaccination alerts, and communicate important updates about your pets\' health.',
              ),
              _PolicySection(
                title: 'Data Storage & Security',
                content:
                    'Your data is securely stored using Google Firebase services. We implement industry-standard security measures to protect your personal information. Pet photos are stored locally on your device and are not uploaded to our servers.',
              ),
              _PolicySection(
                title: 'Sharing of Information',
                content:
                    'We do not sell or share your personal information with third parties. Your pet\'s health information may be accessed by authorized veterinary staff at Vet District Animal Clinic for the purpose of providing medical care.',
              ),
              _PolicySection(
                title: 'Your Rights',
                content:
                    'You have the right to access, update, or delete your personal information at any time through the app Settings. You may also request account deletion which will permanently remove all your data from our systems.',
              ),
              _PolicySection(
                title: 'Contact Us',
                content:
                    'If you have questions about this Privacy Policy, please contact us at vetdistrictclinic@email.com',
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;

  const _PolicySection({required this.title, required this.content});

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
