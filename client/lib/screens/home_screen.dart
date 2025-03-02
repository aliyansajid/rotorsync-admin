import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of screens/pages (using Text widgets as placeholders)
  final List<Widget> _screens = [
    const _HomePage(),
    const _PlaceholderScreen(title: 'Users Screen'),
    const _PlaceholderScreen(title: 'Devices Screen'),
    const _PlaceholderScreen(title: 'Settings Screen'),
  ];

  // Handle item selection
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

  // Build the bottom navigation bar
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

  // Build a navigation item
  BottomNavigationBarItem _buildNavItem(
      IconData icon, String label, int index) {
    final bool isActive = _selectedIndex == index;

    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Icon(
          icon,
          color: isActive ? AppColors.primary : AppColors.grey,
        ),
      ),
      label: label,
    );
  }

  // Label text style
  TextStyle _labelTextStyle({required bool isActive}) {
    return TextStyle(
      fontSize: 12,
      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
      color: isActive ? AppColors.primary : AppColors.grey,
    );
  }
}

// Home page widget
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

// Placeholder screen widget
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
