import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local_ent_280/core/config/google_maps_config.dart';
import 'package:local_ent_280/core/services/current_location_service.dart';
import 'package:local_ent_280/core/services/directions_service.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/features/trips/data/models/trip_location.dart';

/// Google Map layer for driver screens (home preview, trip request, active trip).
class DriverMapLayer extends StatefulWidget {
  const DriverMapLayer({
    super.key,
    this.pickup,
    this.destination,
    this.showRoute = false,
    this.myLocationEnabled = true,
    this.initialZoom = 13,
    this.overlay,
    this.extraMarkers = const [],
    this.fitToExtraMarkers = false,
  });

  final TripLocation? pickup;
  final TripLocation? destination;
  final bool showRoute;
  final bool myLocationEnabled;
  final double initialZoom;
  final Widget? overlay;
  final List<({double latitude, double longitude, bool isDriver})> extraMarkers;
  final bool fitToExtraMarkers;

  @override
  State<DriverMapLayer> createState() => _DriverMapLayerState();
}

class _DriverMapLayerState extends State<DriverMapLayer> {
  final _locationService = CurrentLocationService();
  final _directionsService = DirectionsService();
  GoogleMapController? _mapController;

  LatLng? _myLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _loadingRoute = false;

  @override
  void initState() {
    super.initState();
    _loadMap();
  }

  @override
  void didUpdateWidget(covariant DriverMapLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pickup != widget.pickup ||
        oldWidget.destination != widget.destination ||
        oldWidget.showRoute != widget.showRoute ||
        oldWidget.extraMarkers != widget.extraMarkers) {
      _loadMap();
    }
  }

  Future<void> _loadMap() async {
    final location = await _locationService.getLastKnownLocation() ??
        await _locationService.getCurrentLocation();
    if (!mounted) return;

    final myLatLng = location != null
        ? LatLng(location.latitude, location.longitude)
        : const LatLng(GoogleMapsConfig.lisbonLat, GoogleMapsConfig.lisbonLng);

    setState(() => _myLocation = myLatLng);
    await _buildMarkersAndRoute(myLatLng);
    _fitCamera();
  }

  Future<void> _buildMarkersAndRoute(LatLng myLatLng) async {
    final markers = <Marker>{};
    final pickup = widget.pickup;
    final destination = widget.destination;

    if (pickup != null && pickup.latitude != 0 && pickup.longitude != 0) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(pickup.latitude, pickup.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }
    if (destination != null &&
        destination.latitude != 0 &&
        destination.longitude != 0) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(destination.latitude, destination.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    for (var i = 0; i < widget.extraMarkers.length; i++) {
      final point = widget.extraMarkers[i];
      if (point.latitude == 0 && point.longitude == 0) continue;
      markers.add(
        Marker(
          markerId: MarkerId('extra_$i'),
          position: LatLng(point.latitude, point.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            point.isDriver
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueOrange,
          ),
        ),
      );
    }

    Set<Polyline> polylines = {};
    if (widget.showRoute && pickup != null && destination != null) {
      setState(() => _loadingRoute = true);
      final origin = LatLng(pickup.latitude, pickup.longitude);
      final dest = LatLng(destination.latitude, destination.longitude);
      final route = await _directionsService.getDrivingRoute(
        origin: origin,
        destination: dest,
      );
      if (mounted) {
        polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: route.polylinePoints,
            color: AppColors.accent,
            width: 4,
          ),
        };
        setState(() => _loadingRoute = false);
      }
    }

    if (mounted) {
      setState(() {
        _markers = markers;
        _polylines = polylines;
      });
    }
  }

  void _fitCamera() {
    final controller = _mapController;
    if (controller == null) return;

    final points = <LatLng>[];
    if (_myLocation != null) points.add(_myLocation!);
    final pickup = widget.pickup;
    final destination = widget.destination;
    if (pickup != null && pickup.latitude != 0) {
      points.add(LatLng(pickup.latitude, pickup.longitude));
    }
    if (destination != null && destination.latitude != 0) {
      points.add(LatLng(destination.latitude, destination.longitude));
    }
    if (widget.fitToExtraMarkers) {
      for (final point in widget.extraMarkers) {
        if (point.latitude != 0 || point.longitude != 0) {
          points.add(LatLng(point.latitude, point.longitude));
        }
      }
    }

    if (points.isEmpty) return;
    if (points.length == 1) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, widget.initialZoom),
      );
      return;
    }

    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;
    for (final point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        48,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final target = _myLocation ??
        const LatLng(GoogleMapsConfig.lisbonLat, GoogleMapsConfig.lisbonLng);

    return Stack(
      fit: StackFit.expand,
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: target,
            zoom: widget.initialZoom,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            _fitCamera();
          },
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: widget.myLocationEnabled,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
        if (_loadingRoute)
          const Positioned(
            top: 12,
            right: 12,
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        if (widget.overlay != null) widget.overlay!,
      ],
    );
  }
}
