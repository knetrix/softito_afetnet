// Canlı Akış durumu: olaylar, filtreler, mesafeler, yeni panik bildirimi.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/help_type.dart';
import '../../../core/services/location_service.dart';
import '../../../core/widgets/state_view.dart';
import '../../safety_signal/domain/safety_signal.dart';
import '../../teams/domain/team.dart';
import '../../teams/domain/teams_repository.dart';
import '../domain/incident.dart';
import '../domain/incident_summary.dart';
import '../domain/live_feed_repository.dart';
import 'feed_labels.dart';

/// Canlı Akış filtresi: tümü, bir öncelik veya bir ihtiyaç türü.
/// Filtre yüklenen liste üzerinde istemcide uygulanır (Kural 1; ek index yok).
@immutable
class LiveFeedFilter {
  const LiveFeedFilter._({this.priority, this.type});

  static const all = LiveFeedFilter._();
  const LiveFeedFilter.priority(int p) : this._(priority: p);
  const LiveFeedFilter.type(HelpType t) : this._(type: t);

  final int? priority;
  final HelpType? type;

  bool matches(Incident i) =>
      (priority == null || i.priority == priority) &&
      (type == null || i.type == type);

  @override
  bool operator ==(Object other) =>
      other is LiveFeedFilter &&
      other.priority == priority &&
      other.type == type;

  @override
  int get hashCode => Object.hash(priority, type);
}

/// Y1 — Canlı Akış durumu (PROJECT_NEW.md §3.1 Y1, §4 Kural 1, 5, 8).
class LiveFeedController extends ChangeNotifier {
  LiveFeedController({
    required LiveFeedRepository repository,
    required TeamsRepository teamsRepository,
    LocationService? locationService,
    this.onNewPanicSignal,
  }) : _repo = repository,
       _teamsRepo = teamsRepository,
       _location = locationService {
    _location?.addListener(_onLocationChanged);
    _subscribe();
    unawaited(_location?.refresh());
  }

  final LiveFeedRepository _repo;
  final TeamsRepository _teamsRepo;

  /// Ekip Yönlendir sheet'i bu repository ile görev atar.
  TeamsRepository get teamsRepository => _teamsRepo;
  final LocationService? _location;

  /// Ekran açıkken yeni (ulaşılmamış) panik sinyali gelince çağrılır;
  /// yetkiliye yerel bildirim gösterilir (Kural 8). İlk yüklemede çağrılmaz.
  final void Function(SafetySignal signal)? onNewPanicSignal;

  StreamSubscription<List<Incident>>? _incidentSub;
  StreamSubscription<List<SafetySignal>>? _signalSub;
  StreamSubscription<List<Team>>? _teamSub;
  bool _disposed = false;

  ViewStatus _status = ViewStatus.loading;
  List<Incident> _incidents = const [];
  List<SafetySignal> _signals = const [];
  List<Team> _teams = const [];
  LiveFeedFilter _filter = LiveFeedFilter.all;
  final Map<String, IncidentSummary> _summaries = {};
  final Set<String> _summaryRequested = {};
  Map<String, DateTime>? _seenSignals;

  ViewStatus get status => _status;
  List<Incident> get incidents => _incidents;
  List<SafetySignal> get signals => _signals;
  List<Team> get teams => _teams;
  LiveFeedFilter get filter => _filter;
  LatLng? get userLocation => _location?.currentPosition;

  /// Seçili filtreye uyan olaylar; sıra Firestore'dan gelir (öncelik, zaman).
  List<Incident> get filteredIncidents =>
      _incidents.where(_filter.matches).toList(growable: false);

  /// Ekranda görünen olay listesi boşsa "boş" durumu.
  ViewStatus get listStatus {
    if (_status != ViewStatus.ready) return _status;
    return filteredIncidents.isEmpty ? ViewStatus.empty : ViewStatus.ready;
  }

  IncidentSummary? summaryOf(String incidentId) => _summaries[incidentId];

  Team? teamById(String? id) {
    if (id == null) return null;
    for (final t in _teams) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Ekip Yönlendir: boştaki ekipler, olaya en yakından uzağa; konumu
  /// bilinmeyen ekipler sonda.
  List<Team> availableTeamsFor(Incident incident) => sortTeamsByDistance(
    _teams.where((t) => t.isAvailable),
    incident.location,
  );

  static List<Team> sortTeamsByDistance(Iterable<Team> teams, LatLng target) {
    double d(Team t) => t.location == null
        ? double.infinity
        : FeedLabels.distanceMeters(t.location!, target);
    return teams.toList()..sort((a, b) => d(a).compareTo(d(b)));
  }

  void setFilter(LiveFeedFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    _notify();
  }

  void retry() {
    _status = ViewStatus.loading;
    _notify();
    _subscribe();
  }

  void _subscribe() {
    _incidentSub?.cancel();
    _signalSub?.cancel();
    _teamSub?.cancel();

    _incidentSub = _repo.watchOpenIncidents().listen(
      (list) {
        _incidents = list;
        _status = ViewStatus.ready;
        _loadMissingSummaries(list);
        _notify();
      },
      onError: (Object e) {
        debugPrint('LiveFeed incidents error: $e');
        _status = ViewStatus.failure;
        _notify();
      },
    );

    _signalSub = _repo.watchDangerSignals().listen((list) {
      final fresh = newPanicSignals(_seenSignals, list);
      _seenSignals = {for (final s in list) s.uid: s.updatedAt};
      _signals = list;
      for (final s in fresh) {
        onNewPanicSignal?.call(s);
      }
      _notify();
    }, onError: (Object e) => debugPrint('LiveFeed signals error: $e'));

    _teamSub = _teamsRepo.watchTeams().listen((list) {
      _teams = list;
      _notify();
    }, onError: (Object e) => debugPrint('LiveFeed teams error: $e'));
  }

  /// [seen] (önceki liste: uid → updatedAt) ile karşılaştırıp yeni gelen veya
  /// yenilenen, ulaşılmamış panik sinyallerini döndürür. İlk yüklemede
  /// ([seen] `null`) bildirim üretilmez.
  static List<SafetySignal> newPanicSignals(
    Map<String, DateTime>? seen,
    List<SafetySignal> current,
  ) {
    if (seen == null) return const [];
    return [
      for (final s in current)
        if (s.isDanger &&
            !s.isHandled &&
            (seen[s.uid] == null || s.updatedAt.isAfter(seen[s.uid]!)))
          s,
    ];
  }

  void _loadMissingSummaries(List<Incident> list) {
    for (final incident in list) {
      if (incident.primaryRequestId.isEmpty) continue;
      if (!_summaryRequested.add(incident.id)) continue;
      _repo
          .fetchSummary(incident)
          .then((summary) {
            _summaries[incident.id] = summary;
            _notify();
          })
          .catchError((Object e) {
            // Bir sonraki snapshot'ta yeniden denenir.
            _summaryRequested.remove(incident.id);
            debugPrint('LiveFeed summary error: $e');
          });
    }
  }

  Future<bool> closeIncident(Incident incident) =>
      _repo.closeIncident(incident);

  /// `false`: internet yok, kayıt bağlantı gelince gönderilecek.
  Future<bool> markSignalHandled(SafetySignal signal, String officialUid) =>
      _repo.markSignalHandled(signalUid: signal.uid, officialUid: officialUid);

  Future<IncidentDetail> fetchDetail(Incident incident) =>
      _repo.fetchDetail(incident);

  /// Sheet açıkken olayın güncel hâli (kapandıysa `null`).
  Incident? incidentById(String id) {
    for (final i in _incidents) {
      if (i.id == id) return i;
    }
    return null;
  }

  void _onLocationChanged() => _notify();

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _location?.removeListener(_onLocationChanged);
    _incidentSub?.cancel();
    _signalSub?.cancel();
    _teamSub?.cancel();
    super.dispose();
  }
}
