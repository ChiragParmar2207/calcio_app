import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

/// Glassmorphic settings bottom sheet.
class SettingsSheet extends StatefulWidget {
  final StorageService storage;
  final VoidCallback onChanged;

  const SettingsSheet({
    super.key,
    required this.storage,
    required this.onChanged,
  });

  static void show(BuildContext context, StorageService storage, VoidCallback onChanged) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SettingsSheet(storage: storage, onChanged: onChanged),
    );
  }

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late bool _hapticEnabled;
  late bool _scientificDefault;

  @override
  void initState() {
    super.initState();
    _hapticEnabled = widget.storage.hapticEnabled;
    _scientificDefault = widget.storage.scientificDefault;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.bgCard.withValues(alpha: 0.92),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textDim.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              ShaderMask(
                shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
                child: Text(
                  'Settings',
                  style: AppTheme.displayMedium.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Haptic feedback toggle
              _buildToggle(
                icon: Icons.vibration_rounded,
                title: 'Haptic Feedback',
                subtitle: 'Vibrate on button press',
                value: _hapticEnabled,
                onChanged: (v) {
                  setState(() => _hapticEnabled = v);
                  widget.storage.setHapticEnabled(v);
                  widget.onChanged();
                },
              ),
              const SizedBox(height: 8),
              // Scientific default toggle
              _buildToggle(
                icon: Icons.science_rounded,
                title: 'Scientific Mode Default',
                subtitle: 'Open in scientific mode by default',
                value: _scientificDefault,
                onChanged: (v) {
                  setState(() => _scientificDefault = v);
                  widget.storage.setScientificDefault(v);
                  widget.onChanged();
                },
              ),
              const SizedBox(height: 8),
              // Terms & Conditions
              _buildTappableTile(
                icon: Icons.description_rounded,
                title: 'Terms & Conditions',
                subtitle: 'Read our terms of service',
                onTap: () => _showTermsAndConditions(context),
              ),
              const SizedBox(height: 16),
              // Version info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Calcio v1.0.0',
                  style: AppTheme.historyStyle.copyWith(
                    color: AppTheme.textDim.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Creator credit
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Created with ❤️ by Chirag Parmar',
                  style: AppTheme.historyStyle.copyWith(
                    color: AppTheme.textDim.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: value
                    ? AppTheme.accentStart.withValues(alpha: 0.15)
                    : AppTheme.surface.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20,
                  color: value ? AppTheme.accentStart : AppTheme.textDim),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.buttonTextSmall.copyWith(
                    fontSize: 15,
                  )),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTheme.historyStyle.copyWith(
                    fontSize: 12,
                    color: AppTheme.textDim,
                  )),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppTheme.accentStart,
              activeTrackColor: AppTheme.accentStart.withValues(alpha: 0.3),
              inactiveThumbColor: AppTheme.textDim,
              inactiveTrackColor: AppTheme.surface,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTappableTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentEnd.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppTheme.accentEnd),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.buttonTextSmall.copyWith(
                      fontSize: 15,
                    )),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTheme.historyStyle.copyWith(
                      fontSize: 12,
                      color: AppTheme.textDim,
                    )),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: AppTheme.textDim,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTermsAndConditions(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const _TermsAndConditionsPage();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}

/// Full-screen Terms & Conditions page with glassmorphic design.
class _TermsAndConditionsPage extends StatelessWidget {
  const _TermsAndConditionsPage();

  static const String _lastUpdated = 'May 8, 2026';

  static const List<_TermsSection> _sections = [
    _TermsSection(
      title: '1. Acceptance of Terms',
      body:
          'By downloading, installing, or using Calcio ("the App"), you agree '
          'to be bound by these Terms and Conditions. If you do not agree to these terms, '
          'please do not use the App.',
    ),
    _TermsSection(
      title: '2. License Grant',
      body:
          'We grant you a limited, non-exclusive, non-transferable, revocable license to '
          'use the App for personal, non-commercial purposes on devices you own or control, '
          'subject to these Terms.',
    ),
    _TermsSection(
      title: '3. User Responsibilities',
      body:
          'You agree to use the App only for lawful purposes and in accordance with these '
          'Terms. You are responsible for ensuring the accuracy of any calculations performed '
          'using the App. The App is intended as an aid and should not be solely relied upon '
          'for critical financial, engineering, or scientific calculations.',
    ),
    _TermsSection(
      title: '4. Intellectual Property',
      body:
          'All content, features, and functionality of the App — including but not limited to '
          'design, graphics, text, icons, and software — are the exclusive property of the '
          'developer and are protected by copyright, trademark, and other intellectual '
          'property laws.',
    ),
    _TermsSection(
      title: '5. Limitation of Liability',
      body:
          'The App is provided on an "as is" and "as available" basis. To the fullest extent '
          'permitted by law, we disclaim all warranties, express or implied. We shall not be '
          'liable for any indirect, incidental, special, consequential, or punitive damages '
          'arising from your use of the App.',
    ),
    _TermsSection(
      title: '6. Data & Privacy',
      body:
          'Calcio operates entirely offline. We do not collect, store, or transmit '
          'any personal data. All preferences and calculation history are stored locally on '
          'your device and are never shared with third parties.',
    ),
    _TermsSection(
      title: '7. Updates & Modifications',
      body:
          'We reserve the right to modify, suspend, or discontinue the App at any time '
          'without notice. We may also update these Terms from time to time. Continued use '
          'of the App after changes constitutes acceptance of the updated Terms.',
    ),
    _TermsSection(
      title: '8. Termination',
      body:
          'We may terminate or suspend your access to the App immediately, without prior '
          'notice, for any reason, including breach of these Terms. Upon termination, your '
          'right to use the App will cease immediately.',
    ),
    _TermsSection(
      title: '9. Governing Law',
      body:
          'These Terms shall be governed by and construed in accordance with the laws of '
          'the jurisdiction in which the developer resides, without regard to its conflict '
          'of law provisions.',
    ),
    _TermsSection(
      title: '10. Contact',
      body:
          'If you have any questions about these Terms, please contact us through the '
          'application\'s support channel or the official app store listing.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // Subtle gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0A0A1F),
                  AppTheme.bgDark,
                  Color(0xFF08081A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Decorative accent orb top-right
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accentStart.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Decorative accent orb bottom-left
          Positioned(
            bottom: -80,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accentEnd.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      ShaderMask(
                        shaderCallback: (b) =>
                            AppTheme.primaryGradient.createShader(b),
                        child: Text(
                          'Terms & Conditions',
                          style: AppTheme.displayMedium.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48), // balance for back button
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Last updated badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentStart.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.accentStart.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    'Last updated: $_lastUpdated',
                    style: AppTheme.historyStyle.copyWith(
                      fontSize: 11,
                      color: AppTheme.accentStart,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Scrollable terms
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    itemCount: _sections.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final section = _sections[index];
                      return _buildSectionCard(section);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(_TermsSection section) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (b) =>
                AppTheme.primaryGradient.createShader(b),
            child: Text(
              section.title,
              style: AppTheme.buttonTextSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            section.body,
            style: AppTheme.historyStyle.copyWith(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsSection {
  final String title;
  final String body;

  const _TermsSection({required this.title, required this.body});
}
