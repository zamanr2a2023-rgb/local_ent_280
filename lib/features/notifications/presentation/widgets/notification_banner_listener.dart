import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/navigation/app_navigator_key.dart';
import 'package:local_ent_280/core/services/providers/local_notification_service_provider.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/features/trips/data/active_trip_session.dart';
import '../../application/providers/notification_domain_providers.dart';
import '../../domain/entities/notification_event.dart';
import '../../domain/entities/notification_event_type.dart';

class NotificationBannerListener extends ConsumerStatefulWidget {
  const NotificationBannerListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationBannerListener> createState() {
    return _NotificationBannerListenerState();
  }
}

class _NotificationBannerListenerState
    extends ConsumerState<NotificationBannerListener> {
  StreamSubscription<NotificationEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = ref
        .read(listenNotificationEventsProvider)()
        .listen(_handleEvent, onError: _handleError);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _handleEvent(NotificationEvent event) {
    if (!mounted) {
      return;
    }

    final unfulfilledReason = event.data['unfulfilledReason']?.toString();
    if (event.type == NotificationEventType.clientTripUnfulfilled &&
        _isNoDriverAvailabilityReason(unfulfilledReason)) {
      ActiveTripSession.instance.clear();
      final context = AppNavigatorKey.root.currentContext;
      if (context != null) {
        AppNavigation.toHomeAfterLogin(context);
      }
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }

    final banner = _resolveBanner(event);
    if (banner == null) {
      return;
    }

    unawaited(
      ref.read(localNotificationServiceProvider).show(
            title: banner.title,
            body: banner.message,
          ),
    );
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(AppLayout.marginMobile),
          content: _NotificationBannerContent(
            title: banner.title,
            message: banner.message,
          ),
        ),
      );
  }

  void _handleError(Object error, StackTrace stackTrace) {
    debugPrint('NotificationBannerListener: erro ao escutar notificações.');
    debugPrint('$error');
    debugPrintStack(stackTrace: stackTrace);
  }

  NotificationBannerContent? _resolveBanner(NotificationEvent event) {
    switch (event.type) {
      case NotificationEventType.driverNewTripAssigned:
        return const NotificationBannerContent(
          title: 'Nova viagem',
          message: 'Recebeu um novo pedido de viagem.',
        );
      case NotificationEventType.driverClientExtensionRequested:
        return const NotificationBannerContent(
          title: 'Extensão de viagem',
          message: 'O cliente pediu uma extensão de viagem.',
        );
      case NotificationEventType.clientDriverAssigned:
        return const NotificationBannerContent(
          title: 'Motorista atribuído',
          message: 'Um motorista foi atribuído à sua viagem.',
        );
      case NotificationEventType.clientDriverArrived:
        return const NotificationBannerContent(
          title: 'Motorista chegou',
          message: 'O motorista chegou ao local de recolha.',
        );
      case NotificationEventType.clientTripUnfulfilled:
        if (_isNoDriverAvailabilityReason(
          event.data['unfulfilledReason']?.toString(),
        )) {
          return const NotificationBannerContent(
            title: 'Sem motoristas disponíveis',
            message:
                'Não encontrámos motoristas perto do local de recolha.',
          );
        }
        return const NotificationBannerContent(
          title: 'Viagem não concluída',
          message: 'A viagem não pôde ser concluída.',
        );
      case NotificationEventType.clientTripCompletedCharged:
        return const NotificationBannerContent(
          title: 'Viagem concluída',
          message: 'A viagem foi concluída e o valor foi debitado.',
        );
      case NotificationEventType.clientSupportChatMessage:
        return NotificationBannerContent(
          title: _fallbackTitle(event, defaultTitle: 'Nova mensagem de suporte'),
          message: _fallbackMessage(
            event,
            defaultMessage: 'Recebeu uma nova mensagem no chat de suporte.',
          ),
        );
      case NotificationEventType.clientTripChatMessage:
      case NotificationEventType.driverTripChatMessage:
      case NotificationEventType.opsChatMessage:
        return NotificationBannerContent(
          title: _fallbackTitle(event, defaultTitle: 'Nova mensagem no chat'),
          message: _fallbackMessage(
            event,
            defaultMessage: 'Recebeu uma nova mensagem numa conversa ativa.',
          ),
        );
      case NotificationEventType.opsSupportTicket:
        return NotificationBannerContent(
          title: _fallbackTitle(event, defaultTitle: 'Novo ticket de suporte'),
          message: _fallbackMessage(
            event,
            defaultMessage: 'Existe um novo pedido de suporte para acompanhar.',
          ),
        );
      case NotificationEventType.clientPackageBookingPendingApproval:
      case NotificationEventType.clientPackageBookingApproved:
      case NotificationEventType.clientPackageBookingCancelled:
      case NotificationEventType
          .clientPackageBookingRefundedPreExecutionFailure:
      case NotificationEventType.clientPackageOperationalUpdate:
      case NotificationEventType.driverPackageBookingAcceptanceRequested:
      case NotificationEventType.driverPackageBookingAssigned:
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
        return NotificationBannerContent(
          title: _fallbackTitle(
            event,
            defaultTitle: 'Atualização de package',
          ),
          message: _fallbackMessage(
            event,
            defaultMessage: 'Existe uma nova atualização operacional.',
          ),
        );
      case NotificationEventType.unknown:
        if (event.hasFallbackContent) {
          return NotificationBannerContent(
            title: event.title ?? 'Notificação',
            message: event.body ?? 'Recebeu uma nova notificação.',
          );
        }
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  bool _isNoDriverAvailabilityReason(String? reason) {
    if (reason == null || reason.isEmpty) {
      return false;
    }
    return reason == 'no_drivers' ||
        reason == 'no_available_drivers_status' ||
        reason.startsWith('no_locations_within_') ||
        reason.startsWith('no_available_drivers_near_pickup_within_') ||
        reason == 'no_vehicle_assignment_for_nearby_drivers' ||
        reason == 'nearby_drivers_busy' ||
        reason == 'nearby_drivers_with_reservation_conflict' ||
        reason == 'nearby_drivers_reserved_in_batch' ||
        reason == 'no_assignable_driver_vehicle_candidate' ||
        reason == 'no_remaining_available_drivers';
  }

  String _fallbackTitle(
    NotificationEvent event, {
    required String defaultTitle,
  }) {
    final title = event.title?.trim();
    if (title == null || title.isEmpty) {
      return defaultTitle;
    }
    return title;
  }

  String _fallbackMessage(
    NotificationEvent event, {
    required String defaultMessage,
  }) {
    final body = event.body?.trim();
    if (body == null || body.isEmpty) {
      return defaultMessage;
    }
    return body;
  }
}

class NotificationBannerContent {
  const NotificationBannerContent({required this.title, required this.message});

  final String title;
  final String message;
}

class _NotificationBannerContent extends StatelessWidget {
  const _NotificationBannerContent({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: AppLayout.unit),
        Text(message, style: textTheme.bodySmall),
      ],
    );
  }
}
