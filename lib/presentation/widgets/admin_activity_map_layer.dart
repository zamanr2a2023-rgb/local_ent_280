import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local_ent_280/core/config/google_maps_config.dart';
import 'package:local_ent_280/features/admin/data/models/admin_stats.dart';

/// Firebase-driven map for the admin activity overview.
class AdminActivityMapLayer extends StatefulWidget {
  const AdminActivityMapLayer({
    super.key,
    required this.data,
    this.initialZoom = 11,
  });

  final AdminActivityMapData data;
  final double initialZoom;

  @override
  AdminActivityMapLayerState createState() => AdminActivityMapLayerState();
}

class AdminActivityMapLayerState extends State<AdminActivityMapLayer> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _syncMarkers();
  }

  @override
  void didUpdateWidget(covariant AdminActivityMapLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncMarkers();
    _fitCamera();
  }

  void recenter() => _fitCamera();

  void _syncMarkers() {
    final markers = <Marker>{};
    for (var i = 0; i < widget.data.markers.length; i++) {
      final point = widget.data.markers[i];
      if (point.latitude == 0 && point.longitude == 0) continue;
      markers.add(
        Marker(
          markerId: MarkerId('firebase_$i'),
          position: LatLng(point.latitude, point.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(_hueFor(point.kind)),
          infoWindow: point.label == null || point.label!.trim().isEmpty
              ? InfoWindow.noText
              : InfoWindow(title: point.label!.trim()),
        ),
      );
    }
    setState(() => _markers = markers);
  }

  double _hueFor(AdminMapMarkerKind kind) {
    return switch (kind) {
      AdminMapMarkerKind.tripPickup => BitmapDescriptor.hueOrange,
      AdminMapMarkerKind.tripDestination => BitmapDescriptor.hueRed,
      AdminMapMarkerKind.driver => BitmapDescriptor.hueGreen,
    };
  }

  LatLng _defaultTarget() {
    if (widget.data.hasMapCenter) {
      return LatLng(widget.data.centerLatitude!, widget.data.centerLongitude!);
    }
    return const LatLng(GoogleMapsConfig.lisbonLat, GoogleMapsConfig.lisbonLng);
  }

  void _fitCamera() {
    final controller = _mapController;
    if (controller == null) return;

    final points = widget.data.markers
        .where((m) => m.latitude != 0 || m.longitude != 0)
        .map((m) => LatLng(m.latitude, m.longitude))
        .toList();

    if (points.isEmpty) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_defaultTarget(), widget.initialZoom),
      );
      return;
    }

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
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _defaultTarget(),
        zoom: widget.initialZoom,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
        _fitCamera();
      },
      markers: _markers,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}
