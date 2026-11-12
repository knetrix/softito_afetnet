import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

/// Yetkili alt menüsü: Canlı Akış / Ekipler / Lojistik / Profil (§3.1, T10).
class OfficialShell extends StatelessWidget {
  const OfficialShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.sensors_outlined),
            selectedIcon: const Icon(Icons.sensors_rounded),
            label: l10n?.navLiveFeed ?? 'Canlı Akış',
          ),
          NavigationDestination(
            icon: const Icon(Icons.groups_outlined),
            selectedIcon: const Icon(Icons.groups_rounded),
            label: l10n?.navTeams ?? 'Ekipler',
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2_rounded),
            label: l10n?.navLogistics ?? 'Lojistik',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person_rounded),
            label: l10n?.navProfile ?? 'Profil',
          ),
        ],
      ),
    );
  }
}
