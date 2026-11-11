#!/usr/bin/env bash

# ==============================================================================
# AfetNet — Feature İskeleti Oluşturucu
# Kurallar: PROJECT_NEW.md §6.1 (klasör yapısı) ve flutter-feature-scaffold/SKILL.md
#
# Kullanım (repo kökünden):
#   bash .agents/skills/flutter-feature-scaffold/script/generate_feature.sh <feature> [--ui-only] [--allow-custom-name]
#
#   --ui-only            data/ ve domain/ üretmez; ValueNotifier'lı controller üretir
#                        (whistle, splash, onboarding gibi Firestore'suz ekranlar).
#   --allow-custom-name  §6.1 listesinde olmayan bir ad için (önce G1'e danış).
# ==============================================================================

set -euo pipefail

ALLOWED="splash onboarding auth profile safety_signal home help_request assembly_points whistle live_feed teams logistics broadcast demo_seed"
UI_ONLY_DEFAULT="splash onboarding whistle"

usage() {
  echo "Kullanım: $0 <feature_name> [--ui-only] [--allow-custom-name]"
  echo "İzinli adlar (§6.1): ${ALLOWED}"
  exit 1
}

FEATURE_NAME=""
UI_ONLY=false
ALLOW_CUSTOM=false

for arg in "$@"; do
  case "${arg}" in
    --ui-only) UI_ONLY=true ;;
    --allow-custom-name) ALLOW_CUSTOM=true ;;
    -h|--help) usage ;;
    -*) echo "Hata: bilinmeyen seçenek '${arg}'"; usage ;;
    *)
      if [ -n "${FEATURE_NAME}" ]; then echo "Hata: tek feature adı verilmeli."; usage; fi
      FEATURE_NAME="${arg}"
      ;;
  esac
done

[ -z "${FEATURE_NAME}" ] && usage

# 1) Repo kökünde mi?
if [ ! -f "pubspec.yaml" ] || [ ! -d "lib" ]; then
  echo "Hata: Script repo kökünden çalıştırılmalı (pubspec.yaml ve lib/ bulunamadı)."
  exit 1
fi

# 1b) pubspec.yaml sağlam mı? Paket adı test importları için gerekir.
if grep -qE '^(<<<<<<<|=======|>>>>>>>)' pubspec.yaml; then
  echo "Hata: pubspec.yaml içinde çözülmemiş merge çakışması (<<<<<<< / >>>>>>>) var. Önce onu çöz."
  exit 1
fi
PACKAGE_NAME="$(grep -E '^name:' pubspec.yaml | head -n 1 | sed -E 's/^name:[[:space:]]*//; s/[[:space:]]*$//')"
if [ -z "${PACKAGE_NAME}" ]; then
  echo "Hata: pubspec.yaml içinde 'name:' bulunamadı."
  exit 1
fi

# 2) Ad biçimi: snake_case
FEATURE_NAME="$(echo "${FEATURE_NAME}" | tr '[:upper:]' '[:lower:]' | tr '-' '_')"
if ! [[ "${FEATURE_NAME}" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "Hata: '${FEATURE_NAME}' geçerli bir snake_case ad değil."
  exit 1
fi

# 3) §6.1 listesinde mi?
if ! [[ " ${ALLOWED} " == *" ${FEATURE_NAME} "* ]]; then
  if [ "${ALLOW_CUSTOM}" = false ]; then
    echo "Hata: '${FEATURE_NAME}' PROJECT_NEW.md §6.1 feature listesinde yok."
    echo "İzinli adlar: ${ALLOWED}"
    echo "Gerçekten yeni bir feature gerekiyorsa G1'e danış ve --allow-custom-name ekle."
    exit 1
  fi
  echo "Uyarı: '${FEATURE_NAME}' §6.1 listesinde değil (--allow-custom-name ile devam ediliyor)."
fi

if [ "${UI_ONLY}" = false ] && [[ " ${UI_ONLY_DEFAULT} " == *" ${FEATURE_NAME} "* ]]; then
  echo "Bilgi: '${FEATURE_NAME}' genelde Firestore kullanmaz; --ui-only düşünebilirsin."
fi

# 4) Var olan işin üzerine YAZMA (bayrak yarışı: önceki kişinin kodu korunur)
TARGET_DIR="lib/features/${FEATURE_NAME}"
TEST_DIR="test/features/${FEATURE_NAME}"
if [ -e "${TARGET_DIR}" ]; then
  echo "Hata: ${TARGET_DIR} zaten var. Script hiçbir dosyanın üzerine yazmaz."
  echo "Eksik dosyaları SKILL.md'deki 'Üretilen Yapı'ya bakarak elle ekle."
  exit 1
fi
if [ -e "${TEST_DIR}" ]; then
  echo "Hata: ${TEST_DIR} zaten var. Script hiçbir dosyanın üzerine yazmaz."
  exit 1
fi

to_pascal_case() {
  echo "$1" | awk -F '_' '{for(i=1;i<=NF;i++) printf toupper(substr($i,1,1)) substr($i,2); print ""}'
}
to_camel_case() {
  local p
  p="$(to_pascal_case "$1")"
  echo "$(echo "${p:0:1}" | tr '[:upper:]' '[:lower:]')${p:1}"
}

PASCAL="$(to_pascal_case "${FEATURE_NAME}")"
CAMEL="$(to_camel_case "${FEATURE_NAME}")"

# Şablonlar __PKG__ (paket adı), __NAME__ (snake), __PASCAL__, __CAMEL__ yer tutucularıyla yazılır.
# lib/ içinde göreli import, test/ içinde package: import (avoid_relative_lib_imports).
substitute() {
  sed -e "s/__PKG__/${PACKAGE_NAME}/g" -e "s/__NAME__/${FEATURE_NAME}/g" \
      -e "s/__PASCAL__/${PASCAL}/g" -e "s/__CAMEL__/${CAMEL}/g"
}

# stdin'deki şablonu, adı da yer tutucu içerebilen hedef dosyaya yazar.
render() {
  local out
  out="$(printf '%s' "$1" | substitute)"
  substitute > "${out}"
  echo "  + ${out}"
}

echo "==> '${FEATURE_NAME}' iskeleti oluşturuluyor$( [ "${UI_ONLY}" = true ] && echo ' (--ui-only)')..."
mkdir -p "${TARGET_DIR}/presentation/widgets" "${TEST_DIR}"

if [ "${UI_ONLY}" = true ]; then
# ------------------------------------------------------------------------------
# UI-ONLY: ValueNotifier controller + ekran + test
# ------------------------------------------------------------------------------

render "${TARGET_DIR}/presentation/__NAME___controller.dart" <<'EOF'
import 'package:flutter/foundation.dart';

/// __PASCAL__ ekranının yerel durumu. Firestore'a bağlı değildir.
class __PASCAL__Controller {
  /// TODO: Ekranın gerçek durumuna göre tipini değiştir (örn. düdük: bool isPlaying).
  final ValueNotifier<bool> isActive = ValueNotifier<bool>(false);

  void toggle() => isActive.value = !isActive.value;

  void dispose() {
    isActive.dispose();
  }
}
EOF

render "${TARGET_DIR}/presentation/__NAME___screen.dart" <<'EOF'
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '__NAME___controller.dart';

class __PASCAL__Screen extends StatefulWidget {
  const __PASCAL__Screen({super.key});

  @override
  State<__PASCAL__Screen> createState() => ___PASCAL__ScreenState();
}

class ___PASCAL__ScreenState extends State<__PASCAL__Screen> {
  late final __PASCAL__Controller _controller = __PASCAL__Controller();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.__CAMEL__Title)), // TODO: app_tr.arb + app_en.arb
      body: SafeArea(
        child: Center(
          child: ValueListenableBuilder<bool>(
            valueListenable: _controller.isActive,
            builder: (context, active, _) {
              // TODO: Tasarımdaki bileşeni yerleştir (örn. GlowCircleButton).
              return Switch(value: active, onChanged: (_) => _controller.toggle());
            },
          ),
        ),
      ),
    );
  }
}
EOF

render "${TEST_DIR}/__NAME___controller_test.dart" <<'EOF'
import 'package:flutter_test/flutter_test.dart';

import 'package:__PKG__/features/__NAME__/presentation/__NAME___controller.dart';

void main() {
  group('__PASCAL__Controller', () {
    late __PASCAL__Controller controller;

    setUp(() => controller = __PASCAL__Controller());
    tearDown(() => controller.dispose());

    test('başlangıçta pasif', () {
      expect(controller.isActive.value, isFalse);
    });

    test('toggle durumu değiştirir', () {
      controller.toggle();
      expect(controller.isActive.value, isTrue);
      controller.toggle();
      expect(controller.isActive.value, isFalse);
    });
  });
}
EOF

else
# ------------------------------------------------------------------------------
# TAM: domain + data + presentation + test
# ------------------------------------------------------------------------------
mkdir -p "${TARGET_DIR}/domain" "${TARGET_DIR}/data"

render "${TARGET_DIR}/domain/__NAME___entity.dart" <<'EOF'
import 'package:flutter/foundation.dart';

/// TODO: Gerçek entity adına çevir (örn. Incident, Team, InventoryItem) ve alanları
/// `database/` + PROJECT_NEW.md §5.3 ile birebir yaz. Firestore tipi kullanma.
@immutable
class __PASCAL__Entity {
  const __PASCAL__Entity({
    required this.id,
    required this.name,
    this.updatedAt,
  });

  final String id; // belge kimliği; belgenin içine yazılmaz
  final String name;
  final DateTime? updatedAt;

  __PASCAL__Entity copyWith({String? name, DateTime? updatedAt}) {
    return __PASCAL__Entity(
      id: id,
      name: name ?? this.name,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is __PASCAL__Entity && other.id == id && other.name == name && other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(id, name, updatedAt);
}
EOF

render "${TARGET_DIR}/domain/__NAME___repository.dart" <<'EOF'
import '__NAME___entity.dart';

/// Presentation katmanı yalnızca bu arayüzü bilir; Firestore kodu data/ içindedir.
abstract interface class __PASCAL__Repository {
  Stream<List<__PASCAL__Entity>> watchAll();

  Future<void> save(__PASCAL__Entity entity);
}
EOF

render "${TARGET_DIR}/data/firestore___NAME___repository.dart" <<'EOF'
import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/__NAME___entity.dart';
import '../domain/__NAME___repository.dart';

class Firestore__PASCAL__Repository implements __PASCAL__Repository {
  Firestore__PASCAL__Repository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// TODO: PROJECT_NEW.md §5.1'deki koleksiyon adını yaz.
  CollectionReference<Map<String, dynamic>> get _col => _db.collection('TODO_collection');

  @override
  Stream<List<__PASCAL__Entity>> watchAll() {
    return _col.snapshots().map((snap) => snap.docs.map(_fromDoc).toList());
  }

  @override
  Future<void> save(__PASCAL__Entity entity) {
    return _col.doc(entity.id).set(_toMap(entity), SetOptions(merge: true));
  }

  __PASCAL__Entity _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return __PASCAL__Entity(
      id: doc.id,
      name: d['name'] as String? ?? '',
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> _toMap(__PASCAL__Entity e) => {
        'name': e.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
EOF

render "${TARGET_DIR}/presentation/__NAME___controller.dart" <<'EOF'
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/widgets/state_view.dart';
import '../domain/__NAME___entity.dart';
import '../domain/__NAME___repository.dart';

class __PASCAL__Controller extends ChangeNotifier {
  __PASCAL__Controller(this._repo) {
    _sub = _repo.watchAll().listen(_onData, onError: (Object _) => _setStatus(ViewStatus.failure));
  }

  final __PASCAL__Repository _repo;
  late final StreamSubscription<List<__PASCAL__Entity>> _sub;
  bool _disposed = false;

  ViewStatus _status = ViewStatus.loading;
  ViewStatus get status => _status;

  List<__PASCAL__Entity> _items = const [];
  List<__PASCAL__Entity> get items => _items;

  bool _busy = false;
  bool get busy => _busy;

  /// Başarıyı döner; SnackBar'ı ekran gösterir.
  Future<bool> save(__PASCAL__Entity entity) async {
    if (_busy) return false;
    _busy = true;
    _notify();
    try {
      await _repo.save(entity);
      return true;
    } catch (_) {
      return false;
    } finally {
      _busy = false;
      _notify();
    }
  }

  void _onData(List<__PASCAL__Entity> data) {
    _items = data;
    _setStatus(data.isEmpty ? ViewStatus.empty : ViewStatus.ready);
  }

  void _setStatus(ViewStatus s) {
    _status = s;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _sub.cancel();
    super.dispose();
  }
}
EOF

render "${TARGET_DIR}/presentation/__NAME___screen.dart" <<'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/__NAME___repository.dart';
import '__NAME___controller.dart';
import 'widgets/__NAME___tile.dart';

class __PASCAL__Screen extends StatelessWidget {
  const __PASCAL__Screen({super.key});

  @override
  Widget build(BuildContext context) {
    // __PASCAL__Repository app.dart'taki MultiProvider'a eklenmelidir.
    return ChangeNotifierProvider(
      create: (ctx) => __PASCAL__Controller(ctx.read<__PASCAL__Repository>()),
      child: const ___PASCAL__View(),
    );
  }
}

class ___PASCAL__View extends StatelessWidget {
  const ___PASCAL__View();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.watch<__PASCAL__Controller>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.__CAMEL__Title)), // TODO: app_tr.arb + app_en.arb
      body: SafeArea(
        child: StateView(
          status: c.status,
          emptyMessage: l10n.__CAMEL__Empty, // TODO: app_tr.arb + app_en.arb
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: c.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) => __PASCAL__Tile(entity: c.items[i]),
          ),
        ),
      ),
    );
  }
}
EOF

render "${TARGET_DIR}/presentation/widgets/__NAME___tile.dart" <<'EOF'
import 'package:flutter/material.dart';

import '../../domain/__NAME___entity.dart';

class __PASCAL__Tile extends StatelessWidget {
  const __PASCAL__Tile({super.key, required this.entity, this.onTap});

  final __PASCAL__Entity entity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(entity.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        onTap: onTap, // Ek işlem gerekiyorsa sheet aç (PROJECT_NEW.md §3.2), yeni ekran açma.
      ),
    );
  }
}
EOF

render "${TEST_DIR}/__NAME___controller_test.dart" <<'EOF'
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:__PKG__/core/widgets/state_view.dart';
import 'package:__PKG__/features/__NAME__/domain/__NAME___entity.dart';
import 'package:__PKG__/features/__NAME__/domain/__NAME___repository.dart';
import 'package:__PKG__/features/__NAME__/presentation/__NAME___controller.dart';

class _Fake__PASCAL__Repository implements __PASCAL__Repository {
  final stream = StreamController<List<__PASCAL__Entity>>();
  final saved = <__PASCAL__Entity>[];

  @override
  Stream<List<__PASCAL__Entity>> watchAll() => stream.stream;

  @override
  Future<void> save(__PASCAL__Entity entity) async => saved.add(entity);
}

void main() {
  group('__PASCAL__Controller', () {
    late _Fake__PASCAL__Repository repo;
    late __PASCAL__Controller controller;

    setUp(() {
      repo = _Fake__PASCAL__Repository();
      controller = __PASCAL__Controller(repo);
    });

    tearDown(() {
      controller.dispose();
      repo.stream.close();
    });

    test('başlangıçta loading', () {
      expect(controller.status, ViewStatus.loading);
    });

    test('boş liste gelince empty', () async {
      repo.stream.add(const []);
      await Future<void>.delayed(Duration.zero);
      expect(controller.status, ViewStatus.empty);
    });

    test('veri gelince ready', () async {
      repo.stream.add(const [__PASCAL__Entity(id: '1', name: 'Örnek')]);
      await Future<void>.delayed(Duration.zero);
      expect(controller.status, ViewStatus.ready);
      expect(controller.items, hasLength(1));
    });

    test('hata gelince failure', () async {
      repo.stream.addError(Exception('x'));
      await Future<void>.delayed(Duration.zero);
      expect(controller.status, ViewStatus.failure);
    });

    test('save repository çağırır', () async {
      final ok = await controller.save(const __PASCAL__Entity(id: '2', name: 'Yeni'));
      expect(ok, isTrue);
      expect(repo.saved, hasLength(1));
    });
  });
}
EOF

fi

# 5) Ortak bağımlılık uyarıları (G2'nin işi henüz yoksa derleme hata verir)
echo
for dep in "lib/l10n/app_tr.arb" "lib/l10n/app_en.arb" "lib/core/widgets/state_view.dart"; do
  if [ "${UI_ONLY}" = true ] && [ "${dep}" = "lib/core/widgets/state_view.dart" ]; then continue; fi
  [ -e "${dep}" ] || echo "Uyarı: ${dep} henüz yok (G2). Üretilen kod bu dosya gelene kadar derlenmez."
done

echo
echo "==> Tamamlandı. Sıradaki adımlar:"
echo "  1. ARB: '${CAMEL}Title'$( [ "${UI_ONLY}" = false ] && echo " ve '${CAMEL}Empty'") metnini app_tr.arb + app_en.arb'ye ekle."
if [ "${UI_ONLY}" = false ]; then
  echo "  2. Entity alanlarını ve koleksiyon adını database/ + PROJECT_NEW.md §5'e göre doldur (TODO'lar)."
  echo "  3. Firestore${PASCAL}Repository'yi app.dart MultiProvider'a ekle."
  echo "  4. Ekranı core/router/ içindeki ilgili branch'e bağla."
else
  echo "  2. Ekranı core/router/ içindeki ilgili rota/branch'e bağla."
fi
echo "  Doğrulama: flutter analyze && flutter test ${TEST_DIR}"
