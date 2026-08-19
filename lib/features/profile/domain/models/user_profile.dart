import 'package:cloud_firestore/cloud_firestore.dart';

/// Профиль пользователя, который он сам заполняет —
/// отдельно от данных Firebase Auth (email, дата регистрации и т.д.).
class UserProfile {
  final String firstName;
  final String lastName;
  final String role;
  final String companyInfo;

  const UserProfile({
    this.firstName = '',
    this.lastName = '',
    this.role = '',
    this.companyInfo = '',
  });

  bool get isEmpty =>
      firstName.isEmpty &&
      lastName.isEmpty &&
      role.isEmpty &&
      companyInfo.isEmpty;

  String get fullName => '$firstName $lastName'.trim();

  /// Инициалы для аватара. Если имя не заполнено — пусто,
  /// экран сам решает, что показать вместо них.
  String get initials {
    final firstLetter = firstName.trim().isNotEmpty
        ? firstName.trim()[0].toUpperCase()
        : '';
    final lastLetter = lastName.trim().isNotEmpty
        ? lastName.trim()[0].toUpperCase()
        : '';

    return '$firstLetter$lastLetter';
  }

  /// "Прораб · ИП Сейткали Н.Б." — с аккуратной обработкой
  /// случаев, когда заполнено только одно из полей.
  String get roleLine {
    if (role.isEmpty && companyInfo.isEmpty) return '';
    if (role.isEmpty) return companyInfo;
    if (companyInfo.isEmpty) return role;

    return '$role · $companyInfo';
  }

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? role,
    String? companyInfo,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      companyInfo: companyInfo ?? this.companyInfo,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'companyInfo': companyInfo,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserProfile.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return const UserProfile();

    return UserProfile(
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      role: data['role'] as String? ?? '',
      companyInfo: data['companyInfo'] as String? ?? '',
    );
  }
}
