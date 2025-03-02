import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:rotorsync_admin/screens/users_screen.dart';
import '../constants/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _HomePage(),
    const UsersScreen(),
    const _PlaceholderScreen(title: 'Devices Screen'),
    const _PlaceholderScreen(title: 'Settings Screen'),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.offWhite, width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: _labelTextStyle(isActive: true),
          unselectedLabelStyle: _labelTextStyle(isActive: false),
          elevation: 0,
          items: [
            _buildNavItem(LucideIcons.home, 'Home', 0),
            _buildNavItem(LucideIcons.users, 'Users', 1),
            _buildNavItem(LucideIcons.monitorSmartphone, 'Devices', 2),
            _buildNavItem(LucideIcons.settings, 'Settings', 3),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData icon, String label, int index) {
    final bool isActive = _selectedIndex == index;

    return BottomNavigationBarItem(
      icon: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        tween: Tween<double>(begin: 0, end: isActive ? 1 : 0),
        builder: (context, value, child) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(value),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(value * 0.5),
                  blurRadius: 10 * value,
                  spreadRadius: 2 * value,
                ),
              ],
            ),
            width: 48 + (value * 24),
            child: Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.grey,
            ),
          );
        },
      ),
      label: label,
    );
  }

  TextStyle _labelTextStyle({required bool isActive}) {
    return TextStyle(
      fontSize: 12,
      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
      color: isActive ? AppColors.primary : AppColors.text,
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      alignment: Alignment.center,
      child: const Text(
        'Home Screen',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
