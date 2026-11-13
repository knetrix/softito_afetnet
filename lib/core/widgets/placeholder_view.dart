// Geliştirme sırasında boş sekmeler için geçici görünüm (artık kullanılmıyor).

import 'package:flutter/material.dart';

/// Henüz yazılmamış sekmeler için geçici gövde (G1). Ekranın sahibi kendi
/// adımında bu widget'ı kaldırır; son ekran yazılınca dosya silinir.
class PlaceholderView extends StatelessWidget {
  const PlaceholderView({super.key, required this.title, this.child});

  final String title;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              if (child != null) ...[const SizedBox(height: 16), child!],
            ],
          ),
        ),
      ),
    );
  }
}
