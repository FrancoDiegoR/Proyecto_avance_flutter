import 'package:flutter/material.dart';

import '../../incidentpreventionnotification/presentation/alerts_page.dart';
import '../../kitchenmonitoring/presentation/zones_page.dart';
import 'home_page.dart';

/// Barra inferior del diseno: Home · Zones · Alerts (las otras pestanas quedan para la siguiente entrega).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onSeeAllZones: () => setState(() => _index = 1)),
      const ZonesPage(),
      const AlertsPage(),
    ];

    return Scaffold(
      // IndexedStack conserva el estado de cada pestana al cambiar de una a otra
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'Zonas'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Alertas'),
        ],
      ),
    );
  }
}
