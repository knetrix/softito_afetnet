// A3 Düdük ekranı: dokununca düdük çalar (kırmızı, "ÇALIYOR"), tekrar dokununca durur (turuncu, "DÜDÜK").

import 'package:flutter/material.dart';

import '../../../core/theme/app_status_colors.dart';
import '../../../core/widgets/glow_circle_button.dart';
import '../../../l10n/app_localizations.dart';
import 'whistle_controller.dart';

/// A3 — Çevrimdışı Düdük Ekranı.
///
/// Tamamen internetsiz çalışır. `CitizenShell` içindeki `indexedStack` sekmeyi
/// canlı tuttuğu için kullanıcı başka sekmeye geçse de düdük çalmaya devam eder.
class WhistleScreen extends StatefulWidget {
  const WhistleScreen({super.key, this.controller});

  final WhistleController? controller;

  // Bu StatefulWidget'ın değişen verilerini tutacak State nesnesini oluşturur.
  @override
  State<WhistleScreen> createState() => _WhistleScreenState();
}

// Düdük ekranının animasyonlarını yönetir.
class _WhistleScreenState extends State<WhistleScreen> {
  late final WhistleController _controller =
      widget.controller ?? WhistleController();
  late final bool _ownsController = widget.controller == null;

  // Kapanırken çalışır: dinleyicileri, akışları ve denetleyicileri kapatır (bellek sızıntısı olmasın diye).
  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  // Ekranda görünecek arayüzü (widget ağacını) oluşturur. Veri değişince Flutter bu metodu yeniden çağırır.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final status = theme.extension<AppStatusColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navWhistle),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                // Genişlik de verilir; yoksa Column içeriği kadar daralıp sola yaslanır.
                constraints: BoxConstraints(
                  minWidth: (constraints.maxWidth - 48).clamp(0, double.infinity),
                  minHeight: (constraints.maxHeight - 40).clamp(0, double.infinity),
                ),
                child: ValueListenableBuilder<bool>(
                  valueListenable: _controller.isPlaying,
                  builder: (context, playing, _) {
                    final tint = playing ? status.critical : status.whistle;
                    final title = playing
                        ? l10n.whistlePlayingLabel
                        : l10n.whistleIdleLabel;
                    final subtitle = playing
                        ? l10n.whistlePlayingSubtitle
                        : l10n.whistleIdleSubtitle;
                    final hint = playing
                        ? l10n.whistleTapToStop
                        : l10n.whistleTapToStart;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                if (playing) ...[
                                  _PulseRing(
                                    size: 260,
                                    color: tint,
                                    alpha: 0.10,
                                  ),
                                  _PulseRing(
                                    size: 224,
                                    color: tint,
                                    alpha: 0.18,
                                  ),
                                ],
                                Semantics(
                                  button: true,
                                  toggled: playing,
                                  label: '$title $subtitle',
                                  child: GlowCircleButton(
                                    size: 184,
                                    color: tint,
                                    icon: playing
                                        ? Icons.volume_up_rounded
                                        : Icons.campaign_rounded,
                                    label: title,
                                    isPulsing: playing,
                                    onTap: _controller.toggle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              subtitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: tint,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              hint,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                                letterSpacing: 1.1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.whistleOfflineNote,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Düdük çalarken dalgalanan halka.
class _PulseRing extends StatelessWidget {
  const _PulseRing({
    required this.size,
    required this.color,
    required this.alpha,
  });

  final double size;
  final Color color;
  final double alpha;

  // Ekranda görünecek arayüzü (widget ağacını) oluşturur. Veri değişince Flutter bu metodu yeniden çağırır.
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: alpha),
        ),
      ),
    );
  }
}
