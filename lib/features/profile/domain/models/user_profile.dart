import 'package:cloud_firestore/cloud_firestore.dart';

/// Профиль пользователя, который он сам заполняет.
class UserProfile {
  final String firstName;
  final String lastName;
  final String role;
  final String companyInfo;
  final String? avatarUrl;

  const UserProfile({
    this.firstName = '',
    this.lastName = '',
    this.role = '',
    this.companyInfo = '',
    this.avatarUrl,
  });

  bool get isEmpty =>
      firstName.isEmpty &&
      lastName.isEmpty &&
      role.isEmpty &&
      companyInfo.isEmpty &&
      (avatarUrl == null || avatarUrl!.isEmpty);

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final firstLetter = firstName.trim().isNotEmpty
        ? firstName.trim()[0].toUpperCase()
        : '';
    final lastLetter = lastName.trim().isNotEmpty
        ? lastName.trim()[0].toUpperCase()
        : '';
    return '$firstLetter$lastLetter';
  }

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
    String? avatarUrl,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      companyInfo: companyInfo ?? this.companyInfo,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'companyInfo': companyInfo,
      'avatarUrl': avatarUrl,
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
      avatarUrl: data['avatarUrl'] as String?,
    );
  }
}
