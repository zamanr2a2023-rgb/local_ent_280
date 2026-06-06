import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_ent_280/features/auth/data/models/app_user_role.dart';
import 'package:local_ent_280/l10n/app_localizations.dart';

class AppUserProfile {
  const AppUserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String email;
  final String name;
  final String phone;
  final AppUserRole role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AppUserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw StateError('User profile document is empty.');
    }

    final role = AppUserRole.fromFirestore(data['role'] as String?);
    if (role == null) {
      throw StateError('User profile has an unknown role.');
    }

    return AppUserProfile(
      uid: (data['uid'] as String?) ?? doc.id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: role,
      isActive: data['isActive'] as bool? ?? false,
      createdAt: _timestampToDateTime(data['createdAt']),
      updatedAt: _timestampToDateTime(data['updatedAt']),
    );
  }

  static DateTime? _timestampToDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }

  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      final mail = email.trim();
      return mail.isNotEmpty ? mail[0].toUpperCase() : '?';
    }

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String roleLabel(AppLocalizations l10n) => switch (role) {
        AppUserRole.client => l10n.profileRoleClient,
        AppUserRole.driver => l10n.profileRoleDriver,
        AppUserRole.admin => l10n.profileRoleAdmin,
      };
}
