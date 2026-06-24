import '../domain/entities/notification_event.dart';
import '../domain/entities/notification_event_type.dart';
import 'notification_open_target.dart';

class NotificationOpenRouteResolver {
  const NotificationOpenRouteResolver();

  NotificationOpenTarget? resolve(NotificationEvent event) {
    switch (event.type) {
      case NotificationEventType.driverNewTripAssigned:
      case NotificationEventType.driverClientExtensionRequested:
      case NotificationEventType.driverPackageBookingAcceptanceRequested:
      case NotificationEventType.driverPackageBookingAssigned:
        return NotificationOpenTarget.driverHome;
      case NotificationEventType.clientDriverAssigned:
      case NotificationEventType.clientDriverArrived:
      case NotificationEventType.clientTripUnfulfilled:
      case NotificationEventType.clientTripCompletedCharged:
      case NotificationEventType.clientPackageBookingPendingApproval:
      case NotificationEventType.clientPackageBookingApproved:
      case NotificationEventType.clientPackageBookingCancelled:
      case NotificationEventType
          .clientPackageBookingRefundedPreExecutionFailure:
      case NotificationEventType.clientPackageOperationalUpdate:
        return NotificationOpenTarget.clientHome;
      case NotificationEventType.clientSupportChatMessage:
      case NotificationEventType.clientTripChatMessage:
      case NotificationEventType.driverTripChatMessage:
      case NotificationEventType.opsChatMessage:
      case NotificationEventType.opsSupportTicket:
      case NotificationEventType.opsPackageBookingPendingApproval:
      case NotificationEventType.opsPackageBookingApproved:
      case NotificationEventType.opsPackageBookingRejected:
      case NotificationEventType.opsPackageBookingAwaitingDriverAcceptance:
      case NotificationEventType.opsPackageBookingDriverAssigned:
      case NotificationEventType.opsPackageBookingDriverAccepted:
      case NotificationEventType.opsPackageBookingDriverAcceptanceFailed:
      case NotificationEventType.opsPackageBookingActivationStarted:
      case NotificationEventType.opsPackageBookingActivationFailed:
      case NotificationEventType.opsPackageBookingCancelled:
      case NotificationEventType.opsPackageBookingRefundedPreExecutionFailure:
      case NotificationEventType.opsPackageBookingCompleted:
        return NotificationOpenTarget.adminSupportRequests;
      case NotificationEventType.unknown:
        return null;
    }
  }
}
