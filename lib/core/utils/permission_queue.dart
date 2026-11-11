/// Android aynı anda iki izin penceresi göstermez; ikinci istek hiç dönmez.
/// (Kayıttan sonra bildirim ve konum izni aynı anda isteniyordu.)
/// İzin istekleri bu kuyrukta sırayla çalışır.
abstract final class PermissionQueue {
  static Future<void> _last = Future.value();

  static Future<T> run<T>(Future<T> Function() request) {
    final result = _last.then((_) => request());
    _last = result.then((_) {}, onError: (Object _) {});
    return result;
  }
}
