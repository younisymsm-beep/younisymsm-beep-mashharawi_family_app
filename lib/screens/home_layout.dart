import 'package:flutter/material.dart';
import 'feed_screen.dart';
import 'family_chat_screen.dart';
import 'events_screen.dart';
import 'directory_screen.dart';
import 'profile_screen.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FeedScreen(),
    const FamilyChatScreen(),
    const EventsScreen(),
    const DirectoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'الديوانية'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'المناسبات'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'أفراد العائلة'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}
