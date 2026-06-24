import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:local_ent_280/firebase_options.dart';

/// Calls client Cloud Functions via the callable HTTP endpoint.
///
/// Uses [http] + Firebase Auth token instead of the native
/// [cloud_functions] plugin to avoid platform-channel setup issues.
class ClientFunctionsService {
  ClientFunctionsService({
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

  Future<void> requestTrip({
    required String tripId,
    required Map<String, dynamic> tripData,
  }) async {
    await call('requestTrip', {
      'tripId': tripId,
      'tripData': tripData,
    });
  }

  Future<void> transitionTripState({
    required String tripId,
    required String targetStatus,
    required String actorId,
    String? reason,
    String? assignedDriverId,
    int? assignmentAttempt,
  }) async {
    await call('transitionTripState', {
      'tripId': tripId,
      'targetStatus': targetStatus,
      'actorId': actorId,
      if (reason != null && reason.isNotEmpty) 'reason': reason,
      if (assignedDriverId != null && assignedDriverId.isNotEmpty)
        'assignedDriverId': assignedDriverId,
      if (assignmentAttempt != null) 'assignmentAttempt': assignmentAttempt,
    });
  }

  Future<void> call(String name, Map<String, dynamic> parameters) async {
    final token = await _requireIdToken(forceRefresh: false);
    try {
      await _postCallable(name: name, parameters: parameters, token: token);
    } on ClientFunctionsException catch (error) {
      if (!error.retryWithFreshToken) rethrow;
      final refreshed = await _requireIdToken(forceRefresh: true);
      await _postCallable(name: name, parameters: parameters, token: refreshed);
    }
  }

  Future<String> _requireIdToken({required bool forceRefresh}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const ClientFunctionsException('Not signed in.');
    }
    final token = await user.getIdToken(forceRefresh);
    if (token == null || token.isEmpty) {
      throw const ClientFunctionsException('Could not obtain auth token.');
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
      throw ClientFunctionsException(
        'Invalid response from $name (${response.statusCode}).',
      );
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const ClientFunctionsException(
        'Authentication failed. Sign in again and retry.',
        retryWithFreshToken: true,
      );
    }

    final error = body?['error'];
    if (error is Map) {
      final status = error['status']?.toString() ?? '';
      final message = error['message']?.toString() ?? 'Cloud function failed.';
      final details = error['details'];
      throw ClientFunctionsException(
        _mapCallableStatus(status, message),
        status: status,
        details: details is Map
            ? Map<String, dynamic>.from(details)
            : details,
        retryWithFreshToken: status == 'UNAUTHENTICATED',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ClientFunctionsException(
        'Cloud function failed (${response.statusCode}).',
      );
    }
  }

  String _mapCallableStatus(String status, String message) {
    return switch (status) {
      'FAILED_PRECONDITION' => message,
      'INVALID_ARGUMENT' => message,
      'ALREADY_EXISTS' => message,
      'UNAUTHENTICATED' => 'Authentication failed. Sign in again and retry.',
      _ => message,
    };
  }
}

class ClientFunctionsException implements Exception {
  const ClientFunctionsException(
    this.message, {
    this.status,
    this.details,
    this.retryWithFreshToken = false,
  });

  final String message;
  final String? status;
  final Object? details;
  final bool retryWithFreshToken;

  bool get isLimitExceeded {
    if (details is! Map) return false;
    return (details as Map)['reason']?.toString() == 'LIMIT_EXCEEDED';
  }

  @override
  String toString() => message;
}
