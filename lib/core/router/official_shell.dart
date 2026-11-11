import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Yetkili alt menüsü: Canlı Akış / Ekipler / Lojistik / Profil (§3.1, T10).
// TODO(G2): Etiketleri ARB'ye taşı, tasarımın ikon ve renklerini uygula.
class OfficialShell extends StatelessWidget {
  const OfficialShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.sensors_outlined), label: 'Canlı Akış'),
          NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Ekipler'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Lojistik'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
