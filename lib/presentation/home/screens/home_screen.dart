import 'package:flutter/material.dart';
import 'package:speehive_social/core/utils/extensions.dart';
import 'package:speehive_social/presentation/chat/screens/chat_screen.dart';
import 'package:speehive_social/presentation/settings/screens/settings_screen.dart';
import 'package:speehive_social/presentation/social/screens/social_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    ChatScreen(),
    SocialScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        indicatorColor: cs.primaryContainer,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Social',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
