import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Calls client Cloud Functions via the official [cloud_functions] plugin.
class ClientFunctionsService {
  ClientFunctionsService({
    FirebaseAuth? auth,
    FirebaseFunctions? functions,
    String? region,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _region = region ?? _defaultRegion,
        _functions = functions;

  static const _defaultRegion = 'europe-southwest1';

  static const _callableRegions = {
    'requestTrip': _defaultRegion,
    'transitionTripState': _defaultRegion,
    'cancelTrip': _defaultRegion,
    'requestSupportTicket': _defaultRegion,
    'bookVehicleRental': _defaultRegion,
  };

  final FirebaseAuth _auth;
  final String _region;
  final FirebaseFunctions? _functions;

  FirebaseFunctions _resolveFunctions(String name) {
    if (_functions != null) return _functions;
    final region = _callableRegions[name] ?? _region;
    return FirebaseFunctions.instanceFor(region: region);
  }

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

  Future<void> cancelTrip({
    required String tripId,
    String actor = 'client',
    String type = 'pre_arrival',
    int feeAmountMinor = 0,
    String feeCurrency = 'EUR',
    String? reason,
  }) async {
    await call('cancelTrip', {
      'tripId': tripId,
      'actor': actor,
      'type': type,
      'fee': {
        'amountMinor': feeAmountMinor,
        'currency': feeCurrency,
      },
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });
  }

  Future<void> requestSupportTicket({
    required String subject,
    required String message,
  }) async {
    await call('requestSupportTicket', {
      'subject': subject.trim(),
      'message': message.trim(),
    });
  }

  Future<String> bookVehicleRental({
    required String vehicleId,
    required String vehicleLabel,
    required DateTime scheduledAt,
    required String pickupAddress,
    required String returnAddress,
    required int totalMinor,
    bool fullInsurance = false,
  }) async {
    final result = await callWithResult('bookVehicleRental', {
      'vehicleId': vehicleId,
      'vehicleLabel': vehicleLabel,
      'scheduledAt': scheduledAt.toUtc().toIso8601String(),
      'pickupAddress': pickupAddress,
      'returnAddress': returnAddress,
      'totalMinor': totalMinor,
      'fullInsurance': fullInsurance,
    });
    final reservationId = result?['reservationId'] as String? ?? '';
    if (reservationId.isEmpty) {
      throw const ClientFunctionsException('Reservation could not be confirmed.');
    }
    return reservationId;
  }

  Future<void> call(String name, Map<String, dynamic> parameters) async {
    await callWithResult(name, parameters);
  }

  Future<Map<String, dynamic>?> callWithResult(
    String name,
    Map<String, dynamic> parameters,
  ) async {
    await _ensureSignedIn();
    try {
      return await _invokeCallable(name: name, parameters: parameters);
    } on FirebaseFunctionsException catch (error) {
      if (error.code != 'unauthenticated') {
        throw _mapFunctionsException(error);
      }
      await _auth.currentUser?.getIdToken(true);
      try {
        return await _invokeCallable(name: name, parameters: parameters);
      } on FirebaseFunctionsException catch (retryError) {
        throw _mapFunctionsException(retryError);
      }
    }
  }

  Future<Map<String, dynamic>?> _invokeCallable({
    required String name,
    required Map<String, dynamic> parameters,
  }) async {
    final functions = _resolveFunctions(name);
    final result = await functions.httpsCallable(name).call(parameters);
    final data = result.data;
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  Future<void> _ensureSignedIn() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const ClientFunctionsException('Not signed in.');
    }
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw const ClientFunctionsException('Could not obtain auth token.');
    }
  }

  ClientFunctionsException _mapFunctionsException(
    FirebaseFunctionsException error,
  ) {
    final status = error.code.toUpperCase();
    final message = error.message?.trim().isNotEmpty == true
        ? error.message!.trim()
        : 'Cloud function failed.';
    return ClientFunctionsException(
      _mapCallableStatus(status, message),
      status: status,
      details: error.details,
      retryWithFreshToken: error.code == 'unauthenticated',
    );
  }

  String _mapCallableStatus(String status, String message) {
    return switch (status) {
      'FAILED_PRECONDITION' || 'failed-precondition' => message,
      'INVALID_ARGUMENT' || 'invalid-argument' => message,
      'ALREADY_EXISTS' || 'already-exists' => message,
      'UNAUTHENTICATED' || 'unauthenticated' =>
        'Authentication failed. Sign in again and retry.',
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
