import 'package:firebase_messaging/firebase_messaging.dart';

import '../../domain/entities/notification_event.dart';
import '../../domain/entities/notification_event_type.dart';

class NotificationEventMapper {
  NotificationEvent fromRemoteMessage(RemoteMessage message) {
    final data = _normalizeData(message.data);
    final type = _resolveType(data);

    return NotificationEvent(
      type: type,
      data: data,
      title: message.notification?.title,
      body: message.notification?.body,
    );
  }

  NotificationEventType _resolveType(Map<String, String> data) {
    final rawType =
        data['type'] ?? data['event'] ?? data['notificationType'] ?? '';
    if (rawType.isEmpty) {
      return NotificationEventType.unknown;
    }

    switch (rawType.toLowerCase()) {
      case 'driver.new_trip_assigned':
      case 'driver_new_trip_assigned':
        return NotificationEventType.driverNewTripAssigned;
      case 'driver.client_extension_requested':
      case 'driver_extension_requested':
      case 'driver_client_extension_requested':
        return NotificationEventType.driverClientExtensionRequested;
      case 'client.driver_assigned':
      case 'client_driver_assigned':
        return NotificationEventType.clientDriverAssigned;
      case 'client.driver_arrived':
      case 'client_driver_arrived':
        return NotificationEventType.clientDriverArrived;
      case 'client.trip_unfulfilled':
      case 'client_trip_unfulfilled':
        return NotificationEventType.clientTripUnfulfilled;
      case 'client.trip_completed_charged':
      case 'client_trip_completed_charged':
        return NotificationEventType.clientTripCompletedCharged;
      case 'client.support_chat_message':
      case 'client_support_chat_message':
        return NotificationEventType.clientSupportChatMessage;
      case 'client.trip_chat_message':
      case 'client_trip_chat_message':
        return NotificationEventType.clientTripChatMessage;
      case 'driver.trip_chat_message':
      case 'driver_trip_chat_message':
        return NotificationEventType.driverTripChatMessage;
      case 'ops.chat_message':
      case 'ops_chat_message':
        return NotificationEventType.opsChatMessage;
      case 'ops.support_ticket':
      case 'ops_support_ticket':
        return NotificationEventType.opsSupportTicket;
      case 'client.package_booking_pending_approval':
      case 'client_package_booking_pending_approval':
        return NotificationEventType.clientPackageBookingPendingApproval;
      case 'client.package_booking_approved':
      case 'client_package_booking_approved':
        return NotificationEventType.clientPackageBookingApproved;
      case 'client.package_booking_cancelled':
      case 'client_package_booking_cancelled':
        return NotificationEventType.clientPackageBookingCancelled;
      case 'client.package_booking_refunded_pre_execution_failure':
      case 'client_package_booking_refunded_pre_execution_failure':
        return NotificationEventType
            .clientPackageBookingRefundedPreExecutionFailure;
      case 'client.package_operational_update':
      case 'client_package_operational_update':
        return NotificationEventType.clientPackageOperationalUpdate;
      case 'driver.package_booking_acceptance_requested':
      case 'driver_package_booking_acceptance_requested':
        return NotificationEventType.driverPackageBookingAcceptanceRequested;
      case 'driver.package_booking_assigned':
      case 'driver_package_booking_assigned':
        return NotificationEventType.driverPackageBookingAssigned;
      case 'ops.package_booking_pending_approval':
      case 'ops_package_booking_pending_approval':
        return NotificationEventType.opsPackageBookingPendingApproval;
      case 'ops.package_booking_approved':
      case 'ops_package_booking_approved':
        return NotificationEventType.opsPackageBookingApproved;
      case 'ops.package_booking_rejected':
      case 'ops_package_booking_rejected':
        return NotificationEventType.opsPackageBookingRejected;
      case 'ops.package_booking_awaiting_driver_acceptance':
      case 'ops_package_booking_awaiting_driver_acceptance':
        return NotificationEventType.opsPackageBookingAwaitingDriverAcceptance;
      case 'ops.package_booking_driver_assigned':
      case 'ops_package_booking_driver_assigned':
        return NotificationEventType.opsPackageBookingDriverAssigned;
      case 'ops.package_booking_driver_accepted':
      case 'ops_package_booking_driver_accepted':
        return NotificationEventType.opsPackageBookingDriverAccepted;
      case 'ops.package_booking_driver_acceptance_failed':
      case 'ops_package_booking_driver_acceptance_failed':
        return NotificationEventType.opsPackageBookingDriverAcceptanceFailed;
      case 'ops.package_booking_activation_started':
      case 'ops_package_booking_activation_started':
        return NotificationEventType.opsPackageBookingActivationStarted;
      case 'ops.package_booking_activation_failed':
      case 'ops_package_booking_activation_failed':
        return NotificationEventType.opsPackageBookingActivationFailed;
      case 'ops.package_booking_cancelled':
      case 'ops_package_booking_cancelled':
        return NotificationEventType.opsPackageBookingCancelled;
      case 'ops.package_booking_refunded_pre_execution_failure':
      case 'ops_package_booking_refunded_pre_execution_failure':
        return NotificationEventType
            .opsPackageBookingRefundedPreExecutionFailure;
      case 'ops.package_booking_completed':
      case 'ops_package_booking_completed':
        return NotificationEventType.opsPackageBookingCompleted;
    }

    return NotificationEventType.unknown;
  }

  Map<String, String> _normalizeData(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(key, value?.toString() ?? ''));
  }
}
