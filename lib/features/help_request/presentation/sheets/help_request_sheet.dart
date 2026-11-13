// "Yardım Çağrısı Ekle" formu (alttan açılan panel): ihtiyaç türü, kişi sayısı, adres tarifi, açıklama.
// Öncelik türden otomatik hesaplanır; kullanıcı seçmez.

import 'package:flutter/material.dart';

import '../../../../core/constants/help_type.dart';
import '../../../../core/services/offline_queue_service.dart';
import '../../../../core/theme/app_status_colors.dart';
import '../../../../core/utils/priority_policy.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/help_request_draft.dart';

typedef HelpRequestSubmitCallback = Future<dynamic> Function(HelpRequestDraft draft);

/// Afetzede Yardım Çağrısı Formu Sheet'i (PROJECT_NEW.md §3.2, A1, Kural 1).
///
/// Çağrı türü seçimine göre öncelik seviyesi [PriorityPolicy] üzerinden
/// anlık hesaplanır ve [StatusBadge.priority] ile gösterilir.
///
/// Tür varsayılan olarak seçili gelmez: yanlışlıkla "Enkaz Altında" (kritik)
/// gönderilmesin diye afetzede türü kendisi seçer.
Future<HelpRequestDraft?> showHelpRequestSheet(
  BuildContext context, {
  HelpType? initialType,
  int initialPeopleCount = 1,
  String? initialAddressText,
  String? initialDescription,
  HelpRequestSubmitCallback? onSubmit,
}) {
  final l10n = AppLocalizations.of(context);
  return AppBottomSheet.show<HelpRequestDraft>(
    context,
    title: l10n?.helpRequestSheetTitle ?? 'Yardım Çağrısı Ekle',
    child: HelpRequestForm(
      initialType: initialType,
      initialPeopleCount: initialPeopleCount,
      initialAddressText: initialAddressText,
      initialDescription: initialDescription,
      onSubmit: onSubmit,
    ),
  );
}

/// Yardım çağrısı formu bileşeni.
class HelpRequestForm extends StatefulWidget {
  const HelpRequestForm({
    super.key,
    this.initialType,
    this.initialPeopleCount = 1,
    this.initialAddressText,
    this.initialDescription,
    this.onSubmit,
  });

  final HelpType? initialType;
  final int initialPeopleCount;
  final String? initialAddressText;
  final String? initialDescription;
  final HelpRequestSubmitCallback? onSubmit;

  // Bu StatefulWidget'ın değişen verilerini tutacak State nesnesini oluşturur.
  @override
  State<HelpRequestForm> createState() => _HelpRequestFormState();
}

// Formdaki seçimleri (tür, kişi sayısı, metinler) ve gönderimi yönetir.
class _HelpRequestFormState extends State<HelpRequestForm> {
  final _formKey = GlobalKey<FormState>();
  HelpType? _selectedType;
  late int _peopleCount;
  late final TextEditingController _addressController;
  late final TextEditingController _descriptionController;
  bool _isSubmitting = false;

  // Widget ekrana ilk geldiğinde yalnızca bir kez çalışır; dinleyiciler ve başlangıç verileri burada hazırlanır.
  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _peopleCount = widget.initialPeopleCount > 0 ? widget.initialPeopleCount : 1;
    _addressController = TextEditingController(text: widget.initialAddressText ?? '');
    _descriptionController = TextEditingController(text: widget.initialDescription ?? '');
  }

  // Kapanırken çalışır: dinleyicileri, akışları ve denetleyicileri kapatır (bellek sızıntısı olmasın diye).
  @override
  void dispose() {
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Seçili türe göre otomatik hesaplanan öncelik.
  int? get _calculatedPriority =>
      _selectedType == null ? null : PriorityPolicy.calculate(_selectedType!);

  // Kişi sayısını bir artırır.
  void _incrementPeople() {
    if (_peopleCount < 999) {
      setState(() => _peopleCount++);
    }
  }

  // Kişi sayısını bir azaltır (en az 1).
  void _decrementPeople() {
    if (_peopleCount > 1) {
      setState(() => _peopleCount--);
    }
  }

  // Formu doğrular, konumu alır ve çağrıyı gönderir.
  // İnternet yoksa çağrı Hive kuyruğuna yazılır ve kartta "Gönderilmeyi Bekliyor" görünür.
  Future<void> _submit() async {
    final type = _selectedType;
    if (type == null || !_formKey.currentState!.validate()) return;

    final draft = HelpRequestDraft(
      type: type,
      peopleCount: _peopleCount,
      addressText: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    if (widget.onSubmit != null) {
      setState(() => _isSubmitting = true);
      // Hata yakalanmazsa buton sonsuza kadar döner ve kullanıcı çağrının
      // gittiğini sanabilir; hata durumunda aşağıdaki hata mesajı gösterilir.
      Object? result;
      try {
        result = await widget.onSubmit!(draft);
      } catch (e) {
        debugPrint('Yardım çağrısı gönderilemedi: $e');
      }
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      final l10n = AppLocalizations.of(context);
      final status = Theme.of(context).extension<AppStatusColors>()!;
      final messenger = ScaffoldMessenger.of(context);

      if (result == SubmitResult.sent || result == true) {
        Navigator.of(context).pop(draft);
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n?.helpRequestSubmitted ?? 'Yardım çağrınız alındı.'),
            backgroundColor: status.normal,
          ),
        );
      } else if (result == SubmitResult.queued) {
        Navigator.of(context).pop(draft);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              l10n?.helpRequestQueuedOffline ??
                  'İnternet bağlantısı kurulamadı. Çağrınız kuyruğa alındı ve bağlantı sağlandığında merkeze iletilecektir.',
            ),
            backgroundColor: status.urgent,
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n?.genericError ?? 'Bir hata oluştu, lütfen tekrar deneyin.'),
            backgroundColor: status.critical,
          ),
        );
      }
    } else {
      Navigator.of(context).pop(draft);
    }
  }

  // İhtiyaç türünün metni.
  String _helpTypeLabel(BuildContext context, HelpType type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case HelpType.debris:
        return l10n?.helpTypeDebris ?? 'Enkaz Altında';
      case HelpType.medical:
        return l10n?.helpTypeMedical ?? 'Tıbbi Müdahale';
      case HelpType.shelter:
        return l10n?.helpTypeShelter ?? 'Barınma';
      case HelpType.heating:
        return l10n?.helpTypeHeating ?? 'Isınma';
      case HelpType.babyFood:
        return l10n?.helpTypeBabyFood ?? 'Bebek Maması';
      case HelpType.water:
        return l10n?.helpTypeWater ?? 'Su';
      case HelpType.other:
        return l10n?.helpTypeOther ?? 'Diğer';
    }
  }

  // İhtiyaç türünün simgesi.
  IconData _helpTypeIcon(HelpType type) {
    switch (type) {
      case HelpType.debris:
        return Icons.domain_disabled_rounded;
      case HelpType.medical:
        return Icons.medical_services_outlined;
      case HelpType.shelter:
        return Icons.night_shelter_outlined;
      case HelpType.heating:
        return Icons.local_fire_department_outlined;
      case HelpType.babyFood:
        return Icons.child_care_rounded;
      case HelpType.water:
        return Icons.water_drop_outlined;
      case HelpType.other:
        return Icons.more_horiz_rounded;
    }
  }

  // Ekranda görünecek arayüzü (widget ağacını) oluşturur. Veri değişince Flutter bu metodu yeniden çağırır.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Öncelik Bilgilendirme Rozeti (Kural 1 Triage canlı gösterimi)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n?.helpRequestPriorityLabel ?? 'Öncelik Seviyesi',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                if (_calculatedPriority case final priority?)
                  StatusBadge.priority(priority)
                else
                  Text(
                    l10n?.helpRequestSelectType ?? 'İhtiyaç türünü seçin',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // İhtiyaç Türü Başlığı
          Text(
            l10n?.helpRequestTypeSection ?? 'İhtiyaç Türü',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 10),

          // İhtiyaç Türü Seçim Chip'leri
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: HelpType.values.map((type) {
              final isSelected = type == _selectedType;
              final typePriority = PriorityPolicy.calculate(type);
              final statusColors = theme.extension<AppStatusColors>();
              final priorityTint = statusColors?.forPriority(typePriority) ?? colors.primary;

              return ChoiceChip(
                // Onay işareti tür simgesinin üstüne biniyordu; seçim renkle belli.
                showCheckmark: false,
                label: Text(_helpTypeLabel(context, type)),
                avatar: Icon(
                  _helpTypeIcon(type),
                  size: 18,
                  color: isSelected ? priorityTint : colors.onSurfaceVariant,
                ),
                selected: isSelected,
                selectedColor: priorityTint.withValues(alpha: 0.18),
                backgroundColor: colors.surfaceContainerHighest.withValues(alpha: 0.2),
                side: BorderSide(
                  color: isSelected ? priorityTint : colors.outline.withValues(alpha: 0.3),
                  width: isSelected ? 1.5 : 1,
                ),
                labelStyle: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? colors.onSurface : colors.onSurfaceVariant,
                  fontSize: 13,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedType = type);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Kişi Sayısı Stepper
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.groups_outlined,
                  size: 22,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n?.helpRequestPeopleCount ?? 'Etkilenen Kişi Sayısı',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.remove, size: 18),
                  visualDensity: VisualDensity.compact,
                  onPressed: _peopleCount > 1 ? _decrementPeople : null,
                  tooltip: l10n?.helpRequestPeopleDecrease ?? 'Azalt',
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    '$_peopleCount',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.add, size: 18),
                  visualDensity: VisualDensity.compact,
                  onPressed: _incrementPeople,
                  tooltip: l10n?.helpRequestPeopleIncrease ?? 'Artır',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Adres Tarifi Girişi (§5.2 maxLength 300)
          TextFormField(
            controller: _addressController,
            maxLines: 2,
            maxLength: 300,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n?.helpRequestAddress ?? 'Adres Tarifi',
              hintText: l10n?.helpRequestAddressHint ??
                  'Bina no, kat, daire veya belirgin çevre tarifi...',
              prefixIcon: const Icon(Icons.place_outlined, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Açıklama Girişi (§5.2 maxLength 500)
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            maxLength: 500,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: l10n?.helpRequestDescription ?? 'Durum Açıklaması',
              hintText: l10n?.helpRequestDescriptionHint ??
                  'Durumunuzu ve aciliyetinizi kısaca açıklayın...',
              prefixIcon: const Icon(Icons.notes_rounded, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Gönder Butonu
          AppButton.primary(
            label: l10n?.helpRequestSubmit ?? 'Gönder',
            isLoading: _isSubmitting,
            onPressed: _selectedType == null ? null : _submit,
          ),
        ],
      ),
    );
  }
}
