import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Afetzede alt menüsü: Ana Sayfa / Toplanma / Düdük / Profil (§3.1).
// TODO(G2): Etiketleri ARB'ye taşı, tasarımın ikon ve renklerini uygula.
class CitizenShell extends StatelessWidget {
  const CitizenShell({super.key, required this.shell});

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
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Ana Sayfa'),
          NavigationDestination(icon: Icon(Icons.place_outlined), label: 'Toplanma'),
          NavigationDestination(icon: Icon(Icons.campaign_outlined), label: 'Düdük'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
