import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local_ent_280/core/services/app_currency_formatter.dart';
import 'package:local_ent_280/core/services/support_contact_service.dart';
import 'package:local_ent_280/core/services/support_phone_launcher.dart';
import 'package:local_ent_280/core/services/client_functions_service.dart';
import 'package:local_ent_280/core/services/client_tariff_service.dart';
import 'package:local_ent_280/core/services/trip_price_estimator.dart';
import 'package:local_ent_280/core/data/trip_confirm_data.dart';
import 'package:local_ent_280/core/models/trip_directions_result.dart';
import 'package:local_ent_280/core/models/trip_route_draft.dart';
import 'package:local_ent_280/core/policies/service_area_policy.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/features/auth/data/user_session.dart';
import 'package:local_ent_280/features/trips/data/active_trip_session.dart';
import 'package:local_ent_280/features/trips/data/models/trip_location.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';
import 'package:local_ent_280/features/trips/domain/entities/create_trip_input.dart';
import 'package:local_ent_280/app/presentation/providers/repository_scope.dart';
import 'package:local_ent_280/features/trips/domain/repositories/trip_repository.dart';
import 'package:local_ent_280/core/services/directions_service.dart';
import 'package:local_ent_280/core/services/places_details_service.dart';
import 'package:local_ent_280/core/services/transport_types_service.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/localization/transport_type_labels.dart';
import 'package:local_ent_280/presentation/widgets/session_profile_avatar.dart';

/// Confirmação de viagem com mapa — `roles/details.md`.
class TripConfirmScreen extends StatefulWidget {
  const TripConfirmScreen({
    super.key,
    this.route,
    DirectionsService? directionsService,
    PlacesDetailsService? placesDetailsService,
    TransportTypesService? transportTypesService,
    TripRepository? tripRepository,
  })  : _directionsService = directionsService,
        _placesDetailsService = placesDetailsService,
        _transportTypesService = transportTypesService,
        _tripRepository = tripRepository;

  final TripRouteDraft? route;
  final DirectionsService? _directionsService;
  final PlacesDetailsService? _placesDetailsService;
  final TransportTypesService? _transportTypesService;
  final TripRepository? _tripRepository;

  @override
  State<TripConfirmScreen> createState() => _TripConfirmScreenState();
}

enum _RouteLoadFailure {
  none,
  destination,
  directions,
  transportTypes,
}

class _TripConfirmScreenState extends State<TripConfirmScreen> {
  TripRouteDraft? get _route => widget.route;

  @override
  void initState() {
    super.initState();
    if (_route != null) {
      _loadRouteData();
    }
  }

  late final DirectionsService _directionsService =
      widget._directionsService ?? DirectionsService();
  late final PlacesDetailsService _placesDetailsService =
      widget._placesDetailsService ?? PlacesDetailsService();
  late final TransportTypesService _transportTypesService =
      widget._transportTypesService ?? TransportTypesService();
  late final ClientTariffService _tariffService = ClientTariffService();
  final SupportContactService _supportContactService = SupportContactService();
  final SupportPhoneLauncher _supportPhoneLauncher = const SupportPhoneLauncher();
  static const _priceEstimator = TripPriceEstimator();

  GoogleMapController? _mapController;
  TripDirectionsResult? _directions;
  List<TransportTypeOption> _transportOptions = [];
  ClientTariff? _tariff;
  String? _selectedTransportId;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _usedDirectionsFallback = false;
  _RouteLoadFailure _routeFailure = _RouteLoadFailure.none;
  LatLng? _destinationLatLng;
  TripRepository get _tripRepository =>
      widget._tripRepository ?? tripRepositoryOf(context);

  LatLng get _pickupLatLng {
    final route = _route!;
    return LatLng(route.pickupLat, route.pickupLng);
  }

  Future<void> _loadRouteData() async {
    final route = _route;
    if (route == null) return;

    setState(() {
      _isLoading = true;
      _routeFailure = _RouteLoadFailure.none;
      _usedDirectionsFallback = false;
    });

    LatLng? destination;
    if (route.destinationLat != null && route.destinationLng != null) {
      destination = LatLng(route.destinationLat!, route.destinationLng!);
    } else {
      destination = await _placesDetailsService.resolveCoordinates(
        placeId: route.destinationPlaceId,
        address: route.destinationAddress,
      );
    }

    if (!mounted) return;
    if (destination == null) {
      setState(() {
        _destinationLatLng = null;
        _directions = null;
        _transportOptions = [];
        _tariff = null;
        _routeFailure = _RouteLoadFailure.destination;
        _isLoading = false;
      });
      return;
    }

    final routeResult = await _directionsService.getDrivingRouteDetailed(
      origin: _pickupLatLng,
      destination: destination,
    );
    final transportOptions = await _transportTypesService.fetchActiveTypes();
    final tariff = await _tariffService.fetchCurrentTariff();

    if (!mounted) return;
    if (routeResult.directions == null) {
      setState(() {
        _destinationLatLng = destination;
        _directions = null;
        _transportOptions = transportOptions;
        _tariff = tariff;
        _routeFailure = _RouteLoadFailure.directions;
        _isLoading = false;
      });
      return;
    }

    if (transportOptions.isEmpty) {
      setState(() {
        _destinationLatLng = destination;
        _directions = routeResult.directions;
        _transportOptions = [];
        _tariff = tariff;
        _routeFailure = _RouteLoadFailure.transportTypes;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _destinationLatLng = destination;
      _directions = routeResult.directions;
      _usedDirectionsFallback = routeResult.usedFallback;
      _transportOptions = transportOptions;
      _tariff = tariff;
      _selectedTransportId = transportOptions.first.id;
      _routeFailure = _RouteLoadFailure.none;
      _isLoading = false;
    });
    _fitMapToRoute();
  }

  Future<void> _fitMapToRoute() async {
    final controller = _mapController;
    final directions = _directions;
    final destination = _destinationLatLng;
    if (controller == null || directions == null || destination == null) {
      return;
    }

    final points = directions.polylinePoints;
    if (points.isEmpty) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 56));
  }

  double get _distanceKm => _directions?.distanceKm ?? 0;

  int _estimatedTotalMinor(TransportTypeOption transport) {
    final tariff = _tariff;
    if (tariff == null) {
      return (transport.priceForDistanceKm(_distanceKm) * 100).round();
    }
    return _priceEstimator
        .estimate(
          tariff: tariff,
          transportTypeId: transport.id,
          distanceKm: _distanceKm,
          durationMinutes: _directions?.durationMinutes ?? 0,
          transportBaseFallbackMinor: (transport.baseFare * 100).round(),
        )
        .totalMinor;
  }

  TransportTypeOption? get _selectedTransport {
    if (_selectedTransportId == null) return null;
    for (final option in _transportOptions) {
      if (option.id == _selectedTransportId) return option;
    }
    return null;
  }

  double get _totalPrice {
    final transport = _selectedTransport;
    if (transport == null) return 0;
    return _estimatedTotalMinor(transport) / 100;
  }

  String get _formattedTotal {
    if (_routeFailure != _RouteLoadFailure.none || _isLoading) {
      return '—';
    }
    return AppCurrencyFormatter.instance.formatEurMajor(_totalPrice);
  }

  bool get _canConfirm =>
      !_isLoading &&
      !_isSubmitting &&
      _routeFailure == _RouteLoadFailure.none &&
      _selectedTransport != null &&
      _directions != null &&
      _destinationLatLng != null &&
      _estimatedTotalMinor(_selectedTransport!) > 0;

  String? get _routeErrorMessage {
    return switch (_routeFailure) {
      _RouteLoadFailure.destination => context.l10n.tripConfirmDestinationFailed,
      _RouteLoadFailure.directions => context.l10n.tripConfirmDirectionsFailed,
      _RouteLoadFailure.transportTypes =>
        context.l10n.tripConfirmTransportTypesFailed,
      _RouteLoadFailure.none => null,
    };
  }

  void _onConfirmPressed() {
    if (_isSubmitting || _isLoading) return;

    if (UserSession.instance.profile == null) {
      _showMessage(context.l10n.tripConfirmSessionInvalid);
      return;
    }
    if (_routeFailure != _RouteLoadFailure.none) {
      final message = _routeErrorMessage;
      if (message != null) _showMessage(message);
      return;
    }
    if (_destinationLatLng == null ||
        _selectedTransport == null ||
        _directions == null) {
      _showMessage(context.l10n.tripConfirmRouteLoading);
      return;
    }
    final transport = _selectedTransport!;
    if (_estimatedTotalMinor(transport) <= 0) {
      _showMessage(context.l10n.tripConfirmPriceUnavailable);
      return;
    }

    _confirmTrip();
  }

  Future<void> _confirmTrip() async {
    if (_isSubmitting || _isLoading) return;
    final route = _route;
    if (route == null) return;

    final profile = UserSession.instance.profile;
    final destination = _destinationLatLng;
    final transport = _selectedTransport;
    final directions = _directions;

    if (profile == null ||
        destination == null ||
        transport == null ||
        directions == null) {
      return;
    }

    if (!ServiceAreaPolicy.isPickupEligibleForDispatch(
      latitude: route.pickupLat,
      longitude: route.pickupLng,
    )) {
      _showMessage(context.l10n.homePickupOutsideServiceArea);
      return;
    }

    final estimatedTotalMinor = _estimatedTotalMinor(transport);
    if (estimatedTotalMinor <= 0) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final tripId = await _tripRepository.createTrip(
        CreateTripInput(
          clientId: profile.uid,
          pickup: TripLocation(
            address: route.pickupAddress,
            latitude: route.pickupLat,
            longitude: route.pickupLng,
          ),
          destination: TripLocation(
            address: route.destinationAddress,
            latitude: destination.latitude,
            longitude: destination.longitude,
          ),
          transportType: TripTransportType(
            id: transport.id,
            name: localizedTransportTypeLabel(
              context.l10n,
              transport.id,
              fallback: transport.label,
            ),
          ),
          distanceKm: directions.distanceKm,
          durationMinutes: directions.durationMinutes,
          estimatedTotalMinor: estimatedTotalMinor,
        ),
      );

      ActiveTripSession.instance.setTrip(tripId: tripId);
      if (!mounted) return;
      AppNavigation.toDriverSearch(
        context,
        tripId: tripId,
        tripRepository: widget._tripRepository,
      );
    } on ClientFunctionsException catch (error) {
      developer.log(
        'Trip create failed: ${error.status} ${error.message}',
        name: 'TripConfirmScreen',
      );
      if (!mounted) return;
      if (error.isLimitExceeded) {
        try {
          await _showLimitExceededDialog(error.message);
        } catch (dialogError, stackTrace) {
          developer.log(
            'Limit exceeded dialog failed',
            name: 'TripConfirmScreen',
            error: dialogError,
            stackTrace: stackTrace,
          );
          if (!mounted) return;
          _showMessage(error.message);
        }
      } else {
        _showMessage(error.message);
      }
    } on FirebaseException catch (error) {
      developer.log(
        'Trip create failed: ${error.code} ${error.message}',
        name: 'TripConfirmScreen',
      );
      if (!mounted) return;
      final message = error.code == 'permission-denied'
          ? context.l10n.tripConfirmPermissionDenied
          : context.l10n.tripConfirmCreateFailed;
      _showMessage(message);
    } catch (error, stackTrace) {
      developer.log(
        'Trip create failed',
        name: 'TripConfirmScreen',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      _showMessage(context.l10n.tripConfirmCreateFailed);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showLimitExceededDialog(String reason) async {
    String phone = '';
    try {
      phone = await _supportContactService.fetchSupportPhone();
    } catch (error, stackTrace) {
      developer.log(
        'Support phone lookup failed in limit dialog',
        name: 'TripConfirmScreen',
        error: error,
        stackTrace: stackTrace,
      );
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final l10n = context.l10n;
        final body = phone.isEmpty
            ? reason
            : '$reason\n\n${l10n.clientBalanceContactSupport}: $phone';
        return AlertDialog(
          title: Text(l10n.tripConfirmLimitExceeded),
          content: Text(body),
          actions: [
            if (phone.isNotEmpty)
              TextButton(
                onPressed: () async {
                  final result = await _supportPhoneLauncher.call(phone);
                  if (!dialogContext.mounted) return;
                  if (!result.launched) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${l10n.clientBalanceSupportCallFailed} '
                          '(${result.displayPhone})',
                        ),
                      ),
                    );
                  }
                },
                child: Text(l10n.tripConfirmLimitExceededCallSupport),
              ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  Set<Marker> get _markers {
    final destination = _destinationLatLng;
    return {
      Marker(
        markerId: const MarkerId('pickup'),
        position: _pickupLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      if (destination != null)
        Marker(
          markerId: const MarkerId('destination'),
          position: destination,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
    };
  }

  Set<Polyline> get _polylines {
    final directions = _directions;
    if (directions == null || directions.polylinePoints.length < 2) {
      return {};
    }
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        color: AppColors.secondary,
        width: 5,
        points: directions.polylinePoints,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final route = _route;
    if (route == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _ConfirmAppBar(onBack: () => AppNavigation.back(context)),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppLayout.marginMobile),
                    child: Text(
                      context.l10n.tripConfirmDestinationFailed,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final topInset = MediaQuery.paddingOf(context).top + 56.h;
    final destination = _destinationLatLng;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: topInset,
            left: 0,
            right: 0,
            bottom: 0,
            child: _GoogleMapLayer(
              initialTarget: destination ?? _pickupLatLng,
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (controller) {
                _mapController = controller;
                _fitMapToRoute();
              },
            ),
          ),
          Column(
            children: [
              _ConfirmAppBar(onBack: () => AppNavigation.back(context)),
              const Spacer(),
            ],
          ),
          Positioned(
            top: topInset + 12.h,
            right: AppLayout.marginMobile,
            child: Column(
              children: [
                _MapFabButton(
                  icon: Icons.my_location,
                  onTap: () => _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(_pickupLatLng, 14),
                  ),
                ),
                SizedBox(height: 8.h),
                _MapFabButton(
                  icon: Icons.layers,
                  onTap: _fitMapToRoute,
                ),
              ],
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.56,
            minChildSize: 0.36,
            maxChildSize: 0.90,
            snap: true,
            snapSizes: const [0.36, 0.56, 0.90],
            builder: (context, scrollController) {
              return _TripDetailsSheet(
                scrollController: scrollController,
                pickupLabel: route.pickupAddress,
                destinationLabel: route.destinationAddress,
                distanceLabel: _routeFailure == _RouteLoadFailure.none
                    ? (_directions?.formattedDistance ?? '—')
                    : '—',
                durationLabel: _routeFailure == _RouteLoadFailure.none
                    ? (_directions?.formattedDuration ?? '—')
                    : '—',
                routeErrorMessage: _routeErrorMessage,
                showDirectionsFallbackWarning:
                    _usedDirectionsFallback && _routeFailure == _RouteLoadFailure.none,
                isLoading: _isLoading,
                transportOptions: _transportOptions,
                selectedTransportId: _selectedTransportId ?? '',
                estimatePriceMinor: _estimatedTotalMinor,
                totalFormatted: _formattedTotal,
                onTransportSelected: (id) =>
                    setState(() => _selectedTransportId = id),
                isSubmitting: _isSubmitting,
                canConfirm: _canConfirm,
                onConfirm: _onConfirmPressed,
                onRetryRoute: _loadRouteData,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ConfirmAppBar extends StatelessWidget {
  const _ConfirmAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 56.h,
        color: AppColors.background,
        padding: EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.primary,
                size: 24.sp,
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                context.l10n.appNameLocalTransport,
                style: GoogleFonts.manrope(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  height: 32 / 24,
                  color: AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SessionProfileAvatar(
              size: 40.w,
              fontSize: 14.sp,
              onTap: () => AppNavigation.toProfile(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleMapLayer extends StatelessWidget {
  const _GoogleMapLayer({
    required this.initialTarget,
    required this.markers,
    required this.polylines,
    required this.onMapCreated,
  });

  final LatLng initialTarget;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final ValueChanged<GoogleMapController> onMapCreated;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialTarget,
          zoom: 12,
        ),
        onMapCreated: onMapCreated,
        markers: markers,
        polylines: polylines,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
      ),
    );
  }
}

class _MapFabButton extends StatelessWidget {
  const _MapFabButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12.r),
      elevation: 4,
      shadowColor: AppColors.primary.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          width: 48.w,
          height: 48.h,
          child: Icon(icon, color: AppColors.primary, size: 24.sp),
        ),
      ),
    );
  }
}

class _TripDetailsSheet extends StatelessWidget {
  const _TripDetailsSheet({
    required this.scrollController,
    required this.pickupLabel,
    required this.destinationLabel,
    required this.distanceLabel,
    required this.durationLabel,
    required this.routeErrorMessage,
    required this.showDirectionsFallbackWarning,
    required this.isLoading,
    required this.transportOptions,
    required this.selectedTransportId,
    required this.estimatePriceMinor,
    required this.totalFormatted,
    required this.onTransportSelected,
    required this.isSubmitting,
    required this.canConfirm,
    required this.onConfirm,
    required this.onRetryRoute,
  });

  final ScrollController scrollController;
  final String pickupLabel;
  final String destinationLabel;
  final String distanceLabel;
  final String durationLabel;
  final String? routeErrorMessage;
  final bool showDirectionsFallbackWarning;
  final bool isLoading;
  final List<TransportTypeOption> transportOptions;
  final String selectedTransportId;
  final int Function(TransportTypeOption option) estimatePriceMinor;
  final String totalFormatted;
  final ValueChanged<String> onTransportSelected;
  final bool isSubmitting;
  final bool canConfirm;
  final VoidCallback onConfirm;
  final VoidCallback onRetryRoute;

  static double get _sheetRadius => 24.r;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(_sheetRadius)),
      child: Material(
        color: AppColors.surfaceContainerLowest,
        elevation: 12,
        shadowColor: AppColors.primary.withValues(alpha: 0.08),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(
                  AppLayout.marginMobile,
                  8.h,
                  AppLayout.marginMobile,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  Center(
                    child: Container(
                      width: 48.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  if (routeErrorMessage != null) ...[
                    _RouteErrorBanner(
                      message: routeErrorMessage!,
                      onRetry: onRetryRoute,
                    ),
                    SizedBox(height: 16.h),
                  ] else if (showDirectionsFallbackWarning) ...[
                    _RouteWarningBanner(
                      message: context.l10n.tripConfirmDirectionsApproximate,
                    ),
                    SizedBox(height: 16.h),
                  ],
                  _RouteSection(
                    pickupLabel: pickupLabel,
                    destinationLabel: destinationLabel,
                  ),
                  SizedBox(height: 24.h),
                  _TripStatsRow(
                    distanceLabel: distanceLabel,
                    durationLabel: durationLabel,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    context.l10n.tripConfirmTransportType,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      height: 20 / 14,
                      letterSpacing: 0.1,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 108.h,
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (var i = 0; i < transportOptions.length; i++) ...[
                                  if (i > 0) SizedBox(width: 16.w),
                                  Builder(
                                    builder: (context) {
                                      final option = transportOptions[i];
                                      return _TransportOptionCard(
                                        option: option,
                                        priceMinor: estimatePriceMinor(option),
                                        selected: option.id == selectedTransportId,
                                        onTap: () => onTransportSelected(option.id),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                  ),
                  SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppLayout.marginMobile,
                0,
                AppLayout.marginMobile,
                24.h + bottomInset,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(color: AppColors.surfaceVariant),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Icon(
                        Icons.credit_card,
                        size: 22.sp,
                        color: AppColors.onSurfaceVariant,
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          TripConfirmData.cardMask,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Total: $totalFormatted',
                        style: GoogleFonts.manrope(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          height: 24 / 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    height: 56.h,
                    child: FilledButton(
                      onPressed:
                          isSubmitting ? null : onConfirm,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.onSecondary,
                        elevation: 6,
                        shadowColor: AppColors.secondary.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isSubmitting) ...[
                            SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onSecondary,
                              ),
                            ),
                            SizedBox(width: 8.w),
                          ],
                          Text(
                            context.l10n.tripConfirmTrip,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(Icons.chevron_right, size: 24.sp),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteErrorBanner extends StatelessWidget {
  const _RouteErrorBanner({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(context.l10n.tryAgain),
          ),
        ],
      ),
    );
  }
}

class _RouteWarningBanner extends StatelessWidget {
  const _RouteWarningBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.secondary, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteSection extends StatelessWidget {
  const _RouteSection({
    required this.pickupLabel,
    required this.destinationLabel,
  });

  final String pickupLabel;
  final String destinationLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(
                  Icons.radio_button_checked,
                  color: AppColors.primaryContainer,
                  size: 22.sp,
                ),
                Container(
                  width: 2.w,
                  height: 40.h,
                  margin: EdgeInsets.symmetric(vertical: 4.h),
                  color: AppColors.outlineVariant,
                ),
              ],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.tripConfirmPickupPoint,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    pickupLabel,
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      height: 28 / 18,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  const Divider(height: 1),
                ],
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on, color: AppColors.secondary, size: 22.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.tripConfirmFinalDestination,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    destinationLabel,
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      height: 28 / 18,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TripStatsRow extends StatelessWidget {
  const _TripStatsRow({
    required this.distanceLabel,
    required this.durationLabel,
  });

  final String distanceLabel;
  final String durationLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.straighten,
            iconColor: AppColors.primaryContainer,
            iconBgColor: AppColors.primaryContainer.withValues(alpha: 0.1),
            label: context.l10n.distance,
            value: distanceLabel,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _StatCard(
            icon: Icons.schedule,
            iconColor: AppColors.secondary,
            iconBgColor: AppColors.secondaryContainer.withValues(alpha: 0.1),
            label: context.l10n.duration,
            value: durationLabel,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransportOptionCard extends StatelessWidget {
  const _TransportOptionCard({
    required this.option,
    required this.priceMinor,
    required this.selected,
    required this.onTap,
  });

  final TransportTypeOption option;
  final int priceMinor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final priceText = priceMinor > 0
        ? AppCurrencyFormatter.instance.formatEurMinor(priceMinor)
        : '—';
    final label = localizedTransportTypeLabel(
      context.l10n,
      option.id,
      fallback: option.label,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120.w,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.secondaryContainer.withValues(alpha: 0.05)
              : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? AppColors.secondary : Colors.transparent,
            width: 2.w,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              option.icon,
              size: 24.sp,
              color: selected
                  ? AppColors.secondary
                  : AppColors.onSurfaceVariant,
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              priceText,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.secondary : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
