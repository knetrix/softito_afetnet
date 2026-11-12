import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/firestore_broadcast_repository.dart';

class EvacuationBroadcastSheet extends StatefulWidget {
  const EvacuationBroadcastSheet({super.key, this.repository});

  final FirestoreBroadcastRepository? repository;

  static Future<bool?> open(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const EvacuationBroadcastSheet(),
    );
  }

  @override
  State<EvacuationBroadcastSheet> createState() =>
      _EvacuationBroadcastSheetState();
}

class _EvacuationBroadcastSheetState extends State<EvacuationBroadcastSheet> {
  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _message = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();

  double _radiusKm = 3;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  double? _parseCoordinate(String text) {
    return double.tryParse(text.trim().replaceAll(',', '.'));
  }

  String? _validateLatitude(String? value) {
    final number = _parseCoordinate(value ?? '');

    if (number == null || !number.isFinite || number < -90 || number > 90) {
      return AppLocalizations.of(context)!.broadcastInvalidLatitude;
    }

    return null;
  }

  String? _validateLongitude(String? value) {
    final number = _parseCoordinate(value ?? '');

    if (number == null || !number.isFinite || number < -180 || number > 180) {
      return AppLocalizations.of(context)!.broadcastInvalidLongitude;
    }

    return null;
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) {
      return;
    }

    final strings = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.broadcastLoginRequired)));
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final repository = widget.repository ?? FirestoreBroadcastRepository();

      await repository.createEvacuationBroadcast(
        title: _title.text,
        message: _message.text,
        latitude: _parseCoordinate(_latitude.text)!,
        longitude: _parseCoordinate(_longitude.text)!,
        radiusKm: _radiusKm,
        createdBy: uid,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.broadcastSaveFailed(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset + 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.broadcastTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),

              Text(strings.broadcastDescription),

              const SizedBox(height: 16),

              TextFormField(
                controller: _title,
                maxLength: 100,
                decoration: InputDecoration(
                  labelText: strings.broadcastTitleLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return strings.broadcastRequired;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _message,
                maxLength: 500,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: strings.broadcastMessageLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return strings.broadcastRequired;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitude,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: InputDecoration(
                        labelText: strings.broadcastLatitude,
                        hintText: '36.2021',
                        border: const OutlineInputBorder(),
                      ),
                      validator: _validateLatitude,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: TextFormField(
                      controller: _longitude,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: InputDecoration(
                        labelText: strings.broadcastLongitude,
                        hintText: '36.1606',
                        border: const OutlineInputBorder(),
                      ),
                      validator: _validateLongitude,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(strings.broadcastRadius(_radiusKm.toStringAsFixed(1))),

              Slider(
                min: 0.1,
                max: 20,
                divisions: 199,
                value: _radiusKm,
                label: '${_radiusKm.toStringAsFixed(1)} km',
                onChanged: _saving
                    ? null
                    : (value) {
                        setState(() {
                          _radiusKm = value;
                        });
                      },
              ),

              const SizedBox(height: 8),

              Text(strings.broadcastInfo),

              const SizedBox(height: 18),

              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _saving ? strings.broadcastSaving : strings.broadcastSave,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
