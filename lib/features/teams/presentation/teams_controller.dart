// Ekipler ekranının durumu: ekipler, filtre, aktif görevler.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/services/location_service.dart';
import '../../../core/widgets/state_view.dart';
import '../../live_feed/domain/incident.dart';
import '../../live_feed/domain/live_feed_repository.dart';
import '../domain/assignment.dart';
import '../domain/team.dart';
import '../domain/teams_repository.dart';

/// Y2 — Ekipler durumu (PROJECT_NEW.md §3.1 Y2, §4 Kural 6).
class TeamsController extends ChangeNotifier {
  TeamsController({
    required TeamsRepository repository,
    required LiveFeedRepository liveFeedRepository,
    LocationService? locationService,
  }) : _repo = repository,
       _feedRepo = liveFeedRepository,
       _location = locationService {
    _location?.addListener(_notify);
    _subscribe();
  }

  final TeamsRepository _repo;

  /// Görev Ata / Görev Güncelle sheet'leri bu repository ile yazar.
  TeamsRepository get repository => _repo;
  final LiveFeedRepository _feedRepo;
  final LocationService? _location;

  StreamSubscription<List<Team>>? _teamSub;
  StreamSubscription<List<Assignment>>? _assignmentSub;
  StreamSubscription<List<Incident>>? _incidentSub;
  bool _disposed = false;

  ViewStatus _status = ViewStatus.loading;
  List<Team> _teams = const [];
  List<Assignment> _assignments = const [];
  List<Incident> _openIncidents = const [];
  TeamType? _filter;

  ViewStatus get status => _status;
  List<Team> get teams => _teams;
  List<Incident> get openIncidents => _openIncidents;
  TeamType? get filter => _filter;
  LatLng? get userLocation => _location?.currentPosition;

  List<Team> get filteredTeams => _filter == null
      ? _teams
      : _teams.where((t) => t.type == _filter).toList(growable: false);

  ViewStatus get listStatus {
    if (_status != ViewStatus.ready) return _status;
    return filteredTeams.isEmpty ? ViewStatus.empty : ViewStatus.ready;
  }

  int get totalMembers => _teams.fold(0, (sum, t) => sum + t.memberCount);

  int countOf(TeamType type) => _teams.where((t) => t.type == type).length;

  /// Ekibin bitmemiş görevi (Kural 6: ekipte en fazla bir aktif görev).
  Assignment? activeAssignmentOf(String teamId) {
    for (final a in _assignments) {
      if (a.teamId == teamId && a.isActive) return a;
    }
    return null;
  }

  Incident? incidentById(String? id) {
    if (id == null) return null;
    for (final i in _openIncidents) {
      if (i.id == id) return i;
    }
    return null;
  }

  void setFilter(TeamType? type) {
    if (_filter == type) return;
    _filter = type;
    _notify();
  }

  void retry() {
    _status = ViewStatus.loading;
    _notify();
    _subscribe();
  }

  void _subscribe() {
    _teamSub?.cancel();
    _assignmentSub?.cancel();
    _incidentSub?.cancel();

    _teamSub = _repo.watchTeams().listen(
      (list) {
        _teams = list;
        _status = ViewStatus.ready;
        _notify();
      },
      onError: (Object e) {
        debugPrint('Teams error: $e');
        _status = ViewStatus.failure;
        _notify();
      },
    );
    _assignmentSub = _repo.watchActiveAssignments().listen((list) {
      _assignments = list;
      _notify();
    }, onError: (Object e) => debugPrint('Assignments error: $e'));
    _incidentSub = _feedRepo.watchOpenIncidents().listen((list) {
      _openIncidents = list;
      _notify();
    }, onError: (Object e) => debugPrint('Teams incidents error: $e'));
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _location?.removeListener(_notify);
    _teamSub?.cancel();
    _assignmentSub?.cancel();
    _incidentSub?.cancel();
    super.dispose();
  }
}
