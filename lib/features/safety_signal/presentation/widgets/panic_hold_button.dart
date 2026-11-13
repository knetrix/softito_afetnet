// PANİĞİM / GÜVENDEYİM butonu. Yanlışlıkla basılmasın diye 2 saniye basılı tutmak gerekir;
// bu sürede etrafında dolan bir halka animasyonu görünür.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_status_colors.dart';
import '../../../../core/widgets/glow_circle_button.dart';
import '../../../../l10n/app_localizations.dart';

/// A1 Panik / Güvendeyim butonu (PROJECT_NEW.md §3.1, §3.3 T8).
///
/// Tehlike kapalıyken 2 sn basılı tutma ile [onTriggerDanger] tetiklenir;
/// tehlike aktifken tek dokunuşla [onMarkSafe] çağrılır.
class PanicHoldButton extends StatefulWidget {
  const PanicHoldButton({
    super.key,
    required this.isDangerActive,
    required this.isBusy,
    required this.onTriggerDanger,
    required this.onMarkSafe,
    this.size = 176,
    this.holdDuration = const Duration(seconds: 2),
  });

  final bool isDangerActive;
  final bool isBusy;
  final VoidCallback onTriggerDanger;
  final VoidCallback onMarkSafe;
  final double size;
  final Duration holdDuration;

  // Bu StatefulWidget'ın değişen verilerini tutacak State nesnesini oluşturur.
  @override
  State<PanicHoldButton> createState() => _PanicHoldButtonState();
}

// 2 sn basılı tutma animasyonunu yönetir.
class _PanicHoldButtonState extends State<PanicHoldButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _holdController;
  bool _triggered = false;

  // Widget ekrana ilk geldiğinde yalnızca bir kez çalışır; dinleyiciler ve başlangıç verileri burada hazırlanır.
  @override
  void initState() {
    super.initState();
    _holdController = AnimationController(
      vsync: this,
      duration: widget.holdDuration,
    )..addStatusListener(_onHoldStatus);
  }

  // Üst widget yeni parametrelerle yeniden çizildiğinde çalışır; değişen değere göre animasyonu günceller.
  @override
  void didUpdateWidget(covariant PanicHoldButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.holdDuration != oldWidget.holdDuration) {
      _holdController.duration = widget.holdDuration;
    }
    if (widget.isDangerActive != oldWidget.isDangerActive || widget.isBusy) {
      _cancelHold();
    }
  }

  // Animasyon tamamlanınca butonun işlemini çalıştırır.
  void _onHoldStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_triggered) {
      _triggered = true;
      HapticFeedback.heavyImpact();
      widget.onTriggerDanger();
    }
  }

  // Basılı tutma başladı: animasyonu başlatır.
  void _startHold() {
    if (widget.isBusy || widget.isDangerActive) return;
    _triggered = false;
    HapticFeedback.selectionClick();
    _holdController.forward(from: 0);
  }

  // Parmak erken kalktı: animasyonu geri sarar.
  void _cancelHold() {
    if (_holdController.isAnimating || _holdController.value > 0) {
      _holdController.reset();
    }
  }

  // Kapanırken çalışır: dinleyicileri, akışları ve denetleyicileri kapatır (bellek sızıntısı olmasın diye).
  @override
  void dispose() {
    _holdController.removeStatusListener(_onHoldStatus);
    _holdController.dispose();
    super.dispose();
  }

  // Ekranda görünecek arayüzü (widget ağacını) oluşturur. Veri değişince Flutter bu metodu yeniden çağırır.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = theme.extension<AppStatusColors>()!;
    final l10n = AppLocalizations.of(context)!;

    if (widget.isDangerActive) {
      return Semantics(
        button: true,
        label: '${l10n.panicSafeButton} ${l10n.panicSafeSubtitle}',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                GlowCircleButton(
                  size: widget.size,
                  color: status.normal,
                  icon: Icons.verified_user_rounded,
                  label: l10n.panicSafeButton,
                  isPulsing: !widget.isBusy,
                  onTap: widget.isBusy ? () {} : widget.onMarkSafe,
                ),
                if (widget.isBusy)
                  SizedBox(
                    width: widget.size + 18,
                    height: widget.size + 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.5,
                      color: status.normal,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              l10n.panicSafeSubtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                color: status.normal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Semantics(
      button: true,
      label: '${l10n.panicButtonTitle} ${l10n.panicButtonSubtitle}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _startHold(),
            onTapUp: (_) => _cancelHold(),
            onTapCancel: _cancelHold,
            child: SizedBox(
              width: widget.size + 24,
              height: widget.size + 24,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _holdController,
                    builder: (context, _) {
                      return SizedBox(
                        width: widget.size + 18,
                        height: widget.size + 18,
                        child: CircularProgressIndicator(
                          value: widget.isBusy ? null : _holdController.value,
                          strokeWidth: 4.5,
                          backgroundColor:
                              status.critical.withValues(alpha: 0.2),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(status.critical),
                        ),
                      );
                    },
                  ),
                  IgnorePointer(
                    child: GlowCircleButton(
                      size: widget.size,
                      color: status.critical,
                      icon: Icons.sensors_rounded,
                      label: l10n.panicButtonTitle,
                      isPulsing: !widget.isBusy,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.panicButtonSubtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: status.critical,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

