import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local_ent_280/core/config/google_maps_config.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/services/current_location_service.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';

Future<DeviceLocation?> showPickupMapPickerSheet(
  BuildContext context, {
  required CurrentLocationService locationService,
  double? initialLatitude,
  double? initialLongitude,
}) {
  return showModalBottomSheet<DeviceLocation>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    builder: (context) => _PickupMapPickerSheet(
      locationService: locationService,
      initialLatitude: initialLatitude,
      initialLongitude: initialLongitude,
    ),
  );
}

class _PickupMapPickerSheet extends StatefulWidget {
  const _PickupMapPickerSheet({
    required this.locationService,
    this.initialLatitude,
    this.initialLongitude,
  });

  final CurrentLocationService locationService;
  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<_PickupMapPickerSheet> createState() => _PickupMapPickerSheetState();
}

class _PickupMapPickerSheetState extends State<_PickupMapPickerSheet> {
  GoogleMapController? _mapController;
  LatLng _center = const LatLng(
    GoogleMapsConfig.defaultMapLat,
    GoogleMapsConfig.defaultMapLng,
  );
  bool _loading = true;
  bool _submitting = false;
  String? _previewAddress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeCenter());
  }

  Future<void> _initializeCenter() async {
    LatLng? target;
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      target = LatLng(widget.initialLatitude!, widget.initialLongitude!);
    } else {
      final current = await widget.locationService.getCurrentLocation() ??
          await widget.locationService.getLastKnownLocation();
      if (current != null) {
        target = LatLng(current.latitude, current.longitude);
      }
    }

    if (!mounted) return;
    setState(() {
      _center = target ?? _center;
      _loading = false;
    });
    await _updatePreviewAddress(_center);
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_center, 15),
    );
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _loading = true);
    final current = await widget.locationService.getCurrentLocation() ??
        await widget.locationService.getLastKnownLocation();
    if (!mounted) return;
    if (current == null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.homeLocationUnavailable)),
      );
      return;
    }

    final target = LatLng(current.latitude, current.longitude);
    setState(() {
      _center = target;
      _previewAddress = current.address;
      _loading = false;
    });
    await _mapController?.animateCamera(CameraUpdate.newLatLng(target));
  }

  Future<void> _updatePreviewAddress(LatLng target) async {
    final location = await widget.locationService.locationFromCoordinates(
      latitude: target.latitude,
      longitude: target.longitude,
    );
    if (!mounted) return;
    setState(() => _previewAddress = location.address);
  }

  Future<void> _confirmSelection() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final location = await widget.locationService.locationFromCoordinates(
        latitude: _center.latitude,
        longitude: _center.longitude,
      );
      if (!mounted) return;
      Navigator.of(context).pop(location);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mapHeight = MediaQuery.sizeOf(context).height * 0.55;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppLayout.marginMobile,
          AppLayout.lg,
          AppLayout.marginMobile,
          AppLayout.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.homeSelectLocationOnMap,
                    style: GoogleFonts.manrope(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(
              l10n.homeSelectLocationOnMapHint,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppLayout.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: SizedBox(
                height: mapHeight,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _center,
                        zoom: 15,
                      ),
                      onMapCreated: (controller) => _mapController = controller,
                      onCameraMove: (position) => _center = position.target,
                      onCameraIdle: () => _updatePreviewAddress(_center),
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                    ),
                    Icon(
                      Icons.location_on,
                      size: 42.sp,
                      color: AppColors.accent,
                    ),
                    if (_loading)
                      const ColoredBox(
                        color: Color(0x66FFFFFF),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    Positioned(
                      right: 12.w,
                      bottom: 12.h,
                      child: FloatingActionButton.small(
                        heroTag: 'pickup_map_current_location',
                        backgroundColor: AppColors.surfaceContainerLowest,
                        foregroundColor: AppColors.accent,
                        onPressed: _loading ? null : _goToCurrentLocation,
                        child: const Icon(Icons.my_location),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppLayout.md),
            Text(
              _previewAddress ?? l10n.homeLocationLoading,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: AppLayout.lg),
            FilledButton(
              onPressed: _submitting || _loading ? null : _confirmSelection,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.homeUseMapLocation),
            ),
          ],
        ),
      ),
    );
  }
}
