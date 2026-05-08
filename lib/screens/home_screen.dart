import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/haptic_settings.dart';
import '../theme/app_theme.dart';
import '../painters/aurora_painter.dart';
import '../services/storage_service.dart';
import 'calculator_screen.dart';
import 'converter_screen.dart';

/// Root screen with animated aurora background and custom bottom navigation
/// for switching between Calculator and Converter modes.
class HomeScreen extends StatefulWidget {
  final StorageService storage;

  const HomeScreen({super.key, required this.storage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    HapticSettings.light(context);
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return HapticSettings(
      enabled: widget.storage.hapticEnabled,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppTheme.bgDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.bgDark,
        body: Stack(
          children: [
            // Animated aurora background
            const AnimatedAuroraBackground(),
            // Dark overlay to keep readability
            Container(
              color: AppTheme.bgDark.withValues(alpha: 0.82),
            ),
            // Page content
            Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    children: [
                      CalculatorScreen(
                        storage: widget.storage,
                        onSettingsChanged: () => setState(() {}),
                      ),
                      const ConverterScreen(),
                    ],
                  ),
                ),
                // Custom bottom nav
                _buildBottomNav(),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(40, 0, 40, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.bgElevated.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.calculate_rounded,
                    label: 'CALC',
                    isActive: _currentIndex == 0,
                    onTap: () => _onTabTap(0),
                  ),
                  _NavItem(
                    icon: Icons.swap_horiz_rounded,
                    label: 'CONVERT',
                    isActive: _currentIndex == 1,
                    onTap: () => _onTabTap(1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: isActive ? AppTheme.primaryGradient : null,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.accentStart.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isActive ? Colors.white : AppTheme.textDim,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTheme.labelStyle.copyWith(
                  fontSize: 10,
                  color: isActive ? Colors.white : AppTheme.textDim,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
