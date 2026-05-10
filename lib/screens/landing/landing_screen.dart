import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/gradient_button.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverToBoxAdapter(child: _buildHeroSection(context)),
                SliverToBoxAdapter(child: _buildServicesSection()),
                SliverToBoxAdapter(child: _buildFeaturesSection()),
                SliverToBoxAdapter(child: _buildFooter()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Background Decoration ───────────────────────────────────────────────────

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(color: AppTheme.background),
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                AppTheme.primary.withValues(alpha: 0.07),
                Colors.transparent,
              ],
              center: Alignment.topCenter,
              radius: 1.4,
            ),
          ),
        ),
        Positioned(
          top: -80,
          left: -120,
          child: _GlowCircle(size: 320, color: AppTheme.primary.withValues(alpha: 0.06)),
        ),
        Positioned(
          bottom: -60,
          right: -100,
          child: _GlowCircle(size: 360, color: AppTheme.secondary.withValues(alpha: 0.05)),
        ),
        Positioned(
          top: 300,
          right: -60,
          child: _GlowCircle(size: 220, color: AppTheme.accent.withValues(alpha: 0.04)),
        ),
      ],
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppTheme.secondary, AppTheme.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.pets, color: AppTheme.background, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'PawPulse',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),

          // Get Started button
          OutlinedButton(
            onPressed: () => context.go('/onboarding'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: const BorderSide(color: AppTheme.primary, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: Text(
              'Get Started',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Hero Section ─────────────────────────────────────────────────────────────

  Widget _buildHeroSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Glowing paws icon
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primary.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),
              // Orbit ring
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
              ),
              // Inner glowing container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.pets, size: 52, color: AppTheme.primary),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Headline
          Text(
            "Your Pet's Health,\nSmarter.",
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Subheadline
          Text(
            "PawPulse is a smart pet care management platform designed to help pet owners track their pet's health, appointments, and wellbeing in one place.",
            style: GoogleFonts.nunito(
              fontSize: 15,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // CTA Buttons
          GradientButton(
            label: 'Get Started',
            onPressed: () => context.go('/onboarding'),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go('/login'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: Text(
                'Sign In',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─── Services Section ─────────────────────────────────────────────────────────

  Widget _buildServicesSection() {
    const services = [
      _ServiceItem(
        icon: Icons.medical_services_outlined,
        name: 'General Consultation',
        description: 'Comprehensive health assessment for your pet',
      ),
      _ServiceItem(
        icon: Icons.vaccines_outlined,
        name: 'Vaccination',
        description: 'Keep your pet protected with scheduled vaccines',
      ),
      _ServiceItem(
        icon: Icons.content_cut,
        name: 'Grooming',
        description: 'Professional grooming for a clean and happy pet',
      ),
      _ServiceItem(
        icon: Icons.sanitizer_outlined,
        name: 'Dental Cleaning',
        description: "Maintain your pet's oral health and hygiene",
      ),
      _ServiceItem(
        icon: Icons.healing_outlined,
        name: 'Deworming',
        description: 'Parasite prevention and treatment',
      ),
      _ServiceItem(
        icon: Icons.access_time_outlined,
        name: 'Clinic Hours',
        description: 'Open Monday to Saturday, 8:00 AM – 5:00 PM',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Our Veterinary Services'),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.05,
            children: services.map((s) => _ServiceCard(item: s)).toList(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─── Features Section ─────────────────────────────────────────────────────────

  Widget _buildFeaturesSection() {
    const features = [
      _FeatureItem(
        icon: Icons.document_scanner_outlined,
        color: AppTheme.accent,
        title: 'AI Health Scanning',
        description: 'Detect issues early with smart AI analysis.',
      ),
      _FeatureItem(
        icon: Icons.calendar_month_outlined,
        color: AppTheme.secondary,
        title: 'Appointment Scheduling',
        description: 'Book and manage vet visits effortlessly.',
      ),
      _FeatureItem(
        icon: Icons.vaccines_outlined,
        color: AppTheme.primary,
        title: 'Vaccination Tracking',
        description: 'Never miss an important vaccine again.',
      ),
      _FeatureItem(
        icon: Icons.folder_open_outlined,
        color: Color(0xFFB59BFF),
        title: 'Health Records',
        description: 'All medical history in one secure place.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Why Choose PawPulse?'),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: features.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _FeatureCard(item: features[index]),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─── Footer ───────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Divider(color: AppTheme.textSecondary.withValues(alpha: 0.15), thickness: 1),
          const SizedBox(height: 16),
          Text(
            'PawPulse © 2026 · City College of Tagaytay',
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Shared Section Header ────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Accent line
        Container(
          width: 36,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: [AppTheme.secondary, AppTheme.primary],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─── Service Card ─────────────────────────────────────────────────────────────

class _ServiceItem {
  final IconData icon;
  final String name;
  final String description;
  const _ServiceItem({required this.icon, required this.name, required this.description});
}

class _ServiceCard extends StatelessWidget {
  final _ServiceItem item;
  const _ServiceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppTheme.primary.withValues(alpha: 0.15),
            ),
            child: Icon(item.icon, size: 22, color: AppTheme.primary),
          ),
          const SizedBox(height: 10),
          Text(
            item.name,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              item.description,
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Feature Card ─────────────────────────────────────────────────────────────

class _FeatureItem {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  const _FeatureItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem item;
  const _FeatureCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.color.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: item.color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: item.color.withValues(alpha: 0.15),
            ),
            child: Icon(item.icon, size: 22, color: item.color),
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Glow Circle Background Decoration ───────────────────────────────────────

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
