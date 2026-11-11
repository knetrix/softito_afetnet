import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/placeholder_view.dart';
import '../../auth/presentation/auth_controller.dart';

/// A4 — Profil (Afetzede). Şimdilik boş sekme; ekranı G2 yazar.
/// Geçici Çıkış Yap butonu yalnızca giriş akışını denemek içindir.
class CitizenProfileScreen extends StatelessWidget {
  const CitizenProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return PlaceholderView(
      title: auth.currentUser?.fullName ?? 'Profil',
      child: OutlinedButton(
        onPressed: auth.isBusy ? null : auth.signOut,
        child: const Text('Çıkış Yap'),
      ),
    );
  }
}
