import 'package:flutter/material.dart';
import 'package:shape_up_app/pages/feed.dart';
import 'package:shape_up_app/pages/nutrition.dart';
import 'package:shape_up_app/pages/profile.dart';
import 'package:shape_up_app/pages/training.dart';
import 'package:shape_up_app/services/authentication_service.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  String? _profileId;

  @override
  void initState() {
    super.initState();
    _loadProfileId();
  }

  Future<void> _loadProfileId() async {
    String profileId = await AuthenticationService.getProfileId();
    setState(() {
      _profileId = profileId;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      Feed(),
      Training(),
      Nutrition(),
      _profileId != null ? Profile(profileId: _profileId!) : const Center(child: CircularProgressIndicator()),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF191F2B),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Treino',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank_outlined),
            activeIcon: Icon(Icons.food_bank),
            label: 'Nutrição',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}