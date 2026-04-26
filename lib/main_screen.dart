import 'package:flutter/material.dart';

import 'features/home/screens/home_screen.dart';
import 'features/learn/screens/learn_screen.dart';
import 'features/quiz/screens/quiz_screen.dart';
import 'features/stats/activity_screen.dart';
import 'features/bookmark/bookmark_screen.dart';
import 'features/common/widgets/premium_bottom_nav.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _index;
  late final List<Widget> _screens;

  DateTime? _lastBackPress; // 🔥 NEW

  @override
  void initState() {
    super.initState();

    _index = widget.initialIndex;

    _screens = const [
      HomeScreen(),
      LearnScreen(),
      QuizScreen(level: 'N5', category: 'Vocabulary'),
      ActivityScreen(),
      BookmarkScreen(),
    ];
  }

  void _onTabChange(int index) {
    if (index == _index) return;

    setState(() {
      _index = index;
    });
  }

  Future<bool> _onWillPop() async {
    // 👉 If NOT on Home tab → go to Home
    if (_index != 0) {
      setState(() {
        _index = 0;
      });
      return false;
    }

    final now = DateTime.now();

    // 👉 First back press
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );

      return false;
    }

    // 👉 Second back press → exit app
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // 🔥 IMPORTANT

      child: Scaffold(
        extendBody: true,

        body: IndexedStack(
          index: _index,
          children: _screens,
        ),

        bottomNavigationBar: PremiumBottomNav(
          selectedIndex: _index,
          onTap: _onTabChange,
        ),
      ),
    );
  }
}