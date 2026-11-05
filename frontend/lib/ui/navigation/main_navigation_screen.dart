import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../scan/scan_screen.dart';
import '../settings/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    HomeScreen(),
    HistoryScreen(),
    ScanScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 84,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161917) : const Color(0xFFF1F5EC),
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF262C27) : const Color(0xFFE2E7DB),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home
            _buildNavItem(
              index: 0,
              label: 'Home',
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              isDark: isDark,
            ),
            // History
            _buildNavItem(
              index: 1,
              label: 'History',
              icon: Icons.bar_chart_outlined,
              activeIcon: Icons.bar_chart_rounded,
              isDark: isDark,
            ),
            // Center Scan Pill / Button
            GestureDetector(
              onTap: () {
                setState(() => _currentIndex = 2);
              },
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.accentLime : AppColors.primaryGreen,
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppColors.accentLime : AppColors.primaryGreen)
                          .withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.center_focus_strong,
                  color: isDark ? Colors.black : Colors.white,
                  size: 28,
                ),
              ),
            ),
            // Add Manually Quick Action
            InkWell(
              onTap: () => context.push('/manual-add'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 24,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Settings
            _buildNavItem(
              index: 3,
              label: 'Settings',
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings_rounded,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;
    final activeColor = isDark ? AppColors.accentLime : AppColors.primaryGreen;
    final inactiveColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 24,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

