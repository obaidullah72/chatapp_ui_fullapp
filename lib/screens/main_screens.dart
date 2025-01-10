import 'package:fluter_chat_app_provider/screens/profile_screen.dart';
import 'package:fluter_chat_app_provider/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_currentIndex],
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 0.5,
            ),
          ),
        ),
        child: BottomBarDivider(
          items: [
            TabItem(
              icon: Icons.home,
              title: 'Home',
            ),
            TabItem(
              icon: Icons.person,
              title: 'Profile',
            ),
          ],
          backgroundColor: Color(0xFF6C3483), // Purple background
          color: Color(0xFFD5D8DC), // Light grey for unselected items
          colorSelected: Colors.blue, // Purple accent for selected items
          // borderRadius: BorderRadius.circular(25), // Smooth rounded edges
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
            ),
          ],
          animated: true, // Enable animation
          duration: Duration(milliseconds: 300), // Set animation duration
          indexSelected: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index; // Update the current index to change the active screen
            });
          },
        ),
      ),
    );
  }
}
