import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/placeholder_view.dart';
import '../../auth/presentation/auth_controller.dart';

/// Y4 — Profil (Yetkili). Şimdilik boş sekme; ekranı G2 yazar.
/// Geçici Çıkış Yap butonu yalnızca giriş akışını denemek içindir.
class OfficialProfileScreen extends StatelessWidget {
  const OfficialProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return PlaceholderView(
      title: auth.currentUser?.fullName ?? 'Profil',
      child: OutlinedButton(
        onPressed: auth.isBusy ? null : auth.signOut,
        child: const Text('Sistemden Çıkış Yap'),
      ),
    );
  }
}
