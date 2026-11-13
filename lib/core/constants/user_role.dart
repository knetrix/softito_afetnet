// Kullanıcı rolleri: citizen = afetzede, official = yetkili (saha koordinatörü).
// Bu değerler Firestore'daki users/{uid}.role alanına aynen yazılır.

/// `users.role` değerleri. `name` Firestore'a aynen yazılır.
enum UserRole { citizen, official }
