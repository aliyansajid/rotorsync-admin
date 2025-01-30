import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:rotorsync_admin/screens/settings_screen.dart';
import 'users_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        selectedItemColor: const Color(0xFF1D61E7),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.users), label: 'Users'),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.radio), label: 'Sensors'),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
