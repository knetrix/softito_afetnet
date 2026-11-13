// Toplanma ekranının durumunu tutan controller (ChangeNotifier).
// Noktaları ve kullanıcı konumunu dinler; filtre ya da seçim değişince ekrana notifyListeners ile haber verir.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/services/location_service.dart';
import '../domain/assembly_point.dart';
import '../domain/assembly_point_type.dart';
import '../domain/assembly_points_repository.dart';

/// Toplanma Alanları Ekran Kontrolcüsü.
class AssemblyPointsController extends ChangeNotifier {
  AssemblyPointsController({
    required AssemblyPointsRepository repository,
    LocationService? locationService,
    LatLng? initialUserLocation,
  })  : _repo = repository,
        _locationService = locationService,
        _userLocation = initialUserLocation ?? locationService?.currentPosition {
    _init();
  }

  final AssemblyPointsRepository _repo;
  final LocationService? _locationService;

  StreamSubscription<List<AssemblyPoint>>? _subscription;
  List<AssemblyPoint> _points = const [];
  AssemblyPointType? _filter;
  AssemblyPoint? _selectedPoint;
  LatLng? _userLocation;
  bool _isLoading = true;
  bool _disposed = false;

  // Gösterilen toplanma noktaları.
  List<AssemblyPoint> get points => _points;
  // Seçili tür filtresi (null = tümü).
  AssemblyPointType? get filter => _filter;
  // Haritada seçili nokta.
  AssemblyPoint? get selectedPoint => _selectedPoint;
  // Kullanıcının konumu.
  LatLng? get userLocation => _userLocation;
  // Veriler yükleniyor mu.
  bool get isLoading => _isLoading;

  /// Filtrelenmiş ve kullanıcı konumuna olan mesafeye göre sıralanmış liste
  List<AssemblyPoint> get filteredPoints {
    var result = _filter == null
        ? _points
        : _points.where((p) => p.type == _filter).toList();

    if (_userLocation != null) {
      result = List.of(result)
        ..sort((a, b) => a
            .distanceInMeters(_userLocation!)
            .compareTo(b.distanceInMeters(_userLocation!)));
    }
    return result;
  }

  /// Kullanıcı konumuna en yakın ilk 3 alan
  List<AssemblyPoint> get nearestThreePoints {
    final list = filteredPoints;
    return list.take(3).toList();
  }

  // Başlangıçta: toplanma noktalarını Firestore'dan dinlemeye başlar ve kullanıcının konumunu ister.
  void _init() {
    _locationService?.addListener(_onLocationChanged);
    _subscription = _repo.watchAssemblyPoints().listen(
      (data) {
        if (_disposed) return;
        _points = data;
        _isLoading = false;

        // Seçili nokta güncellendiyse referansı tazele
        if (_selectedPoint != null) {
          final updated = _points.where((p) => p.id == _selectedPoint!.id);
          _selectedPoint = updated.isNotEmpty ? updated.first : null;
        }

        if (!_disposed) notifyListeners();
      },
      onError: (_) {
        if (_disposed) return;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Kullanıcının konumu değişince çalışır; mesafeler yeni konuma göre hesaplansın diye ekranı yeniler.
  void _onLocationChanged() {
    final newPos = _locationService?.currentPosition;
    if (newPos != null && newPos != _userLocation) {
      _userLocation = newPos;
      if (!_disposed) notifyListeners();
    }
  }

  /// Haritada veya kartta gösterilecek noktayı seçer
  void selectPoint(AssemblyPoint? point) {
    if (_selectedPoint?.id == point?.id) return;
    _selectedPoint = point;
    notifyListeners();
  }

  /// Tür filtresini değiştirir (null = Tümü)
  void setFilter(AssemblyPointType? type) {
    if (_filter == type) return;
    _filter = type;
    notifyListeners();
  }

  /// Kullanıcı konumunu manuel günceller
  void updateUserLocation(LatLng? location) {
    _userLocation = location;
    notifyListeners();
  }

  /// Seçili toplanma alanına rota / yol tarifi URL'i oluşturur
  static String buildNavigationUrl(AssemblyPoint point) {
    final lat = point.location.latitude;
    final lng = point.location.longitude;
    return 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
  }

  // Kapanırken çalışır: dinleyicileri, akışları ve denetleyicileri kapatır (bellek sızıntısı olmasın diye).
  @override
  void dispose() {
    _disposed = true;
    _locationService?.removeListener(_onLocationChanged);
    _subscription?.cancel();
    super.dispose();
  }
}
