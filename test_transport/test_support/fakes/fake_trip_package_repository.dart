import 'dart:async';

import 'package:local_transport/features/trip_packages/domain/entities/trip_package.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package_booking.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package_booking_request.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package_delete_result.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package_draft.dart';
import 'package:local_transport/features/trip_packages/domain/repositories/trip_package_repository.dart';

class FakeTripPackageRepository implements TripPackageRepository {
  FakeTripPackageRepository({
    List<TripPackage> managementPackages = const <TripPackage>[],
    List<TripPackage>? activePackages,
    List<TripPackageBooking> opsQueueBookings = const <TripPackageBooking>[],
    Map<String, TripPackage?> packagesById = const <String, TripPackage?>{},
    Map<String, TripPackageBooking?> bookingsById =
        const <String, TripPackageBooking?>{},
    List<TripPackageBooking> clientBookings = const <TripPackageBooking>[],
    this.confirmBookingError,
    this.confirmBookingResult = 'booking-1',
    this.deletePackageResult = const TripPackageDeleteResult.empty(),
  }) : _managementPackages = managementPackages,
       _activePackages = activePackages ?? managementPackages,
       _opsQueueBookings = opsQueueBookings,
       _packagesById = packagesById,
       _bookingsById = bookingsById,
       _clientBookings = clientBookings;

  final List<TripPackage> _managementPackages;
  final List<TripPackage> _activePackages;
  final List<TripPackageBooking> _opsQueueBookings;
  final Map<String, TripPackage?> _packagesById;
  final Map<String, TripPackageBooking?> _bookingsById;
  final List<TripPackageBooking> _clientBookings;
  final Exception? confirmBookingError;
  final String confirmBookingResult;
  final TripPackageDeleteResult deletePackageResult;

  final List<TripPackageBookingRequest> confirmRequests =
      <TripPackageBookingRequest>[];
  final List<String> deletedPackageIds = <String>[];
  final List<String> cancelledBookingIds = <String>[];
  final List<String> approvedBookingIds = <String>[];
  final Map<String, String> rejectedBookingReasons = <String, String>{};

  @override
  Stream<List<TripPackage>> watchManagementPackages() =>
      Stream<List<TripPackage>>.value(_managementPackages);

  @override
  Stream<List<TripPackage>> watchActivePackages() =>
      Stream<List<TripPackage>>.value(_activePackages);

  @override
  Stream<TripPackage?> watchPackage(String packageId) =>
      Stream<TripPackage?>.value(_packagesById[packageId]);

  @override
  Stream<List<TripPackageBooking>> watchOpsQueueBookings() =>
      Stream<List<TripPackageBooking>>.value(_opsQueueBookings);

  @override
  Stream<List<TripPackageBooking>> watchClientBookings(String clientId) =>
      Stream<List<TripPackageBooking>>.value(
        _clientBookings
            .where((booking) => booking.clientId == clientId)
            .toList(),
      );

  @override
  Stream<TripPackageBooking?> watchBooking(String bookingId) =>
      Stream<TripPackageBooking?>.value(_bookingsById[bookingId]);

  @override
  Future<String> savePackage(TripPackageDraft draft) async =>
      draft.id ?? 'package-1';

  @override
  Future<void> archivePackage(String packageId) async {}

  @override
  Future<TripPackageDeleteResult> deletePackage(String packageId) async {
    deletedPackageIds.add(packageId);
    return deletePackageResult;
  }

  @override
  Future<String> confirmBooking(TripPackageBookingRequest request) async {
    confirmRequests.add(request);
    if (confirmBookingError != null) {
      throw confirmBookingError!;
    }
    return confirmBookingResult;
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    cancelledBookingIds.add(bookingId);
  }

  @override
  Future<void> approveBooking(String bookingId) async {
    approvedBookingIds.add(bookingId);
  }

  @override
  Future<void> rejectBooking({
    required String bookingId,
    required String reason,
  }) async {
    rejectedBookingReasons[bookingId] = reason;
  }
}
