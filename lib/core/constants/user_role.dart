// Kullanıcı rolleri: citizen = afetzede, official = yetkili (saha koordinatörü).
// Bu değerler Firestore'daki users/{uid}.role alanına aynen yazılır.

/// `users.role` değerleri (PROJECT_NEW.md §2). `name` Firestore'a aynen yazılır.
enum UserRole { citizen, official }
