import 'package:flutter/material.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../core/widgets/home_top_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeTopBar(),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
      ),
      body: const Center(
        child: Text('Home content aayega yahan'),
      ),
    );
  }
}
