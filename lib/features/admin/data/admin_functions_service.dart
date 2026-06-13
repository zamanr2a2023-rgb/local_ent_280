import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:local_ent_280/firebase_options.dart';

/// Calls admin Cloud Functions via the callable HTTP endpoint.
///
/// Uses [http] + Firebase Auth token instead of the native
/// [cloud_functions] plugin to avoid platform-channel setup issues.
class AdminFunctionsService {
  AdminFunctionsService({
    FirebaseAuth? auth,
    http.Client? httpClient,
    String? projectId,
    String? region,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _http = httpClient ?? http.Client(),
        _projectId =
            projectId ?? DefaultFirebaseOptions.currentPlatform.projectId,
        _region = region ?? _defaultRegion;

  static const _defaultRegion = 'europe-southwest1';

  final FirebaseAuth _auth;
  final http.Client _http;
  final String _projectId;
  final String _region;

  Future<void> setManagerPermissions({
    required String userId,
    required Map<String, bool> permissions,
  }) async {
    await call('setManagerPermissions', {
      'userId': userId.trim(),
      'permissions': permissions,
    });
  }

  Future<void> createTransportType({
    required String name,
    required String description,
    required int baseFareMinor,
    int packageMultiplierBasisPoints = 10000,
  }) async {
    await call('createTransportType', {
      'name': name.trim(),
      'description': description.trim(),
      'initialBaseFare': {'amountMinor': baseFareMinor, 'currency': 'EUR'},
      'packagePriceMultiplierBasisPoints': packageMultiplierBasisPoints,
    });
  }

  Future<void> updateTransportType({
    required String id,
    required String name,
    required String description,
    required int baseFareMinor,
    int packageMultiplierBasisPoints = 10000,
  }) async {
    await call('updateTransportType', {
      'id': id,
      'name': name.trim(),
      'description': description.trim(),
      'baseFare': {'amountMinor': baseFareMinor, 'currency': 'EUR'},
      'packagePriceMultiplierBasisPoints': packageMultiplierBasisPoints,
    });
  }

  Future<void> saveTripPackageTemplate(Map<String, dynamic> template) async {
    await call('saveTripPackageTemplate', template);
  }

  Future<void> resolveSupportRequest(String requestId) async {
    await call('resolvePasswordHelpRequest', {'requestId': requestId});
  }

  Future<void> sendSupportTicketMessage({
    required String requestId,
    required String body,
    required String clientMessageId,
  }) async {
    await call('sendSupportTicketMessage', {
      'requestId': requestId,
      'body': body.trim(),
      'clientMessageId': clientMessageId,
    });
  }

  Future<void> saveAdminTariff(Map<String, dynamic> tariff) async {
    await call('saveAdminTariff', {'tariff': tariff});
  }

  Future<void> call(String name, Map<String, dynamic> parameters) async {
    final token = await _requireIdToken(forceRefresh: false);
    try {
      await _postCallable(name: name, parameters: parameters, token: token);
    } on AdminFunctionsException catch (error) {
      if (!error.retryWithFreshToken) rethrow;
      final refreshed = await _requireIdToken(forceRefresh: true);
      await _postCallable(name: name, parameters: parameters, token: refreshed);
    }
  }

  Future<String> _requireIdToken({required bool forceRefresh}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AdminFunctionsException('Not signed in.');
    }
    final token = await user.getIdToken(forceRefresh);
    if (token == null || token.isEmpty) {
      throw const AdminFunctionsException('Could not obtain auth token.');
    }
    return token;
  }

  Future<void> _postCallable({
    required String name,
    required Map<String, dynamic> parameters,
    required String token,
  }) async {
    final uri = Uri.parse(
      'https://$_region-$_projectId.cloudfunctions.net/$name',
    );
    final response = await _http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'data': parameters}),
    );

    Map<String, dynamic>? body;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        body = decoded;
      } else if (decoded is Map) {
        body = Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      throw AdminFunctionsException(
        'Invalid response from $name (${response.statusCode}).',
      );
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const AdminFunctionsException(
        'Authentication failed. Sign in again and retry.',
        retryWithFreshToken: true,
      );
    }

    final error = body?['error'];
    if (error is Map) {
      final status = error['status']?.toString() ?? '';
      final message = error['message']?.toString() ?? 'Cloud function failed.';
      throw AdminFunctionsException(
        _mapCallableStatus(status, message),
        retryWithFreshToken: status == 'UNAUTHENTICATED',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AdminFunctionsException(
        'Cloud function failed (${response.statusCode}).',
      );
    }
  }

  String _mapCallableStatus(String status, String message) {
    return switch (status) {
      'PERMISSION_DENIED' => 'Admin access required.',
      'NOT_FOUND' => 'Manager account not found.',
      'FAILED_PRECONDITION' => message,
      'INVALID_ARGUMENT' => message,
      'UNAUTHENTICATED' => 'Authentication failed. Sign in again and retry.',
      _ => message,
    };
  }
}

class AdminFunctionsException implements Exception {
  const AdminFunctionsException(
    this.message, {
    this.retryWithFreshToken = false,
  });

  final String message;
  final bool retryWithFreshToken;

  @override
  String toString() => message;
}
