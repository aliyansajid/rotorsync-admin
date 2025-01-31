import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:rotorsync_admin/screens/settings_screen.dart';
import 'users_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const Center(child: Text('Home Screen', style: TextStyle(fontSize: 20))),
    const UsersScreen(),
    const Center(child: Text('Sensors Screen', style: TextStyle(fontSize: 20))),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1D61E7),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: _labelTextStyle(isSelected: true),
        unselectedLabelStyle: _labelTextStyle(isSelected: false),
        items: [
          _buildNavItem(LucideIcons.home, 'Home', 0),
          _buildNavItem(LucideIcons.users, 'Users', 1),
          _buildNavItem(LucideIcons.radio, 'Sensors', 2),
          _buildNavItem(LucideIcons.settings, 'Settings', 3),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;

    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFF1D61E7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFF1D61E7) : Colors.grey,
        ),
      ),
      label: label,
    );
  }

  TextStyle _labelTextStyle({required bool isSelected}) {
    return TextStyle(
      fontSize: 12,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      color: isSelected ? const Color(0xFF1D61E7) : Colors.grey,
    );
  }
}
