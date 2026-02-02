import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myenvato/controller/home/bottom_nav_controller.dart';
import 'package:myenvato/screens/earnings/earnings_screen.dart';
import 'package:myenvato/screens/home/dashboard_screen.dart';
import 'package:myenvato/screens/portfolio/portfolio_screen.dart';
import 'package:myenvato/screens/settings/settings_screen.dart';
import 'package:myenvato/screens/statement/statement_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  final BottomNavController _navController = Get.put(BottomNavController());

  late final List<Widget> _pages = [
    DashboardScreen(),
    EarningsScreen(),
    StatementScreen(),
    const PortfolioScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Obx(() {
        return IndexedStack(
          index: _navController.currentIndex.value,
          children: _pages,
        );
      }),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor:
              Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          currentIndex: _navController.currentIndex.value,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
          onTap: (index) {
            _navController.changeTabIndex(index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              label: 'Earns',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Invoice',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work),
              label: 'Items',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Profile',
            ),
          ],
          showUnselectedLabels: true,
        );
      }),
    );
  }
}
