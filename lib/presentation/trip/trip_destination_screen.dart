import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/data/trip_destination_data.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/models/trip_route_draft.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/services/current_location_service.dart';
import 'package:local_ent_280/core/services/location_permission_helper.dart';
import 'package:local_ent_280/core/services/places_autocomplete_service.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/presentation/widgets/address_autocomplete_field.dart';
import 'package:local_ent_280/presentation/widgets/app_bottom_nav.dart';
import 'package:local_ent_280/presentation/widgets/client_drawer.dart';
import 'package:local_ent_280/presentation/widgets/current_location_field.dart';
import 'package:local_ent_280/presentation/widgets/session_profile_avatar.dart';

/// Destino da viagem — `roles/details.md` (Para onde vamos hoje?).
class TripDestinationScreen extends StatefulWidget {
  const TripDestinationScreen({super.key});

  @override
  State<TripDestinationScreen> createState() => _TripDestinationScreenState();
}

class _TripDestinationScreenState extends State<TripDestinationScreen> {
  final _destinationController = TextEditingController();
  final _locationService = CurrentLocationService();

  String? _currentAddress;
  double? _pickupLat;
  double? _pickupLng;
  String? _destinationPlaceId;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationAccess();
    });
  }

  Future<void> _requestLocationAccess() async {
    if (!mounted) return;
    setState(() => _isLoadingLocation = true);

    final granted = await LocationPermissionHelper.ensureGranted(context);
    if (!mounted) return;

    if (!granted) {
      setState(() {
        _isLoadingLocation = false;
        _currentAddress = null;
        _pickupLat = null;
        _pickupLng = null;
      });
      return;
    }

    await _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    final cached = await _locationService.getLastKnownLocation();
    if (mounted && cached != null) {
      setState(() {
        _currentAddress = cached.address;
        _pickupLat = cached.latitude;
        _pickupLng = cached.longitude;
      });
    }

    final location = await _locationService.getCurrentLocation();
    if (!mounted) return;
    setState(() {
      _isLoadingLocation = false;
      _currentAddress = location?.address ?? _currentAddress;
      _pickupLat = location?.latitude ?? _pickupLat;
      _pickupLng = location?.longitude ?? _pickupLng;
    });
  }

  void _onDestinationSelected(PlacePrediction prediction) {
    _destinationPlaceId = prediction.placeId;
  }

  void _selectPlace(TripPlace place) {
    _destinationController.text = place.title;
    _destinationPlaceId = null;
    setState(() {});
  }

  void _openTripConfirm(BuildContext context) {
    final l10n = context.l10n;
    final pickup = _currentAddress?.trim();
    final destination = _destinationController.text.trim();

    if (pickup == null || pickup.isEmpty || _pickupLat == null || _pickupLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.homeLocationUnavailable)),
      );
      return;
    }
    if (destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.homeDestinationHint)),
      );
      return;
    }

    AppNavigation.toTripConfirm(
      context,
      TripRouteDraft(
        pickupAddress: pickup,
        pickupLat: _pickupLat!,
        pickupLng: _pickupLng!,
        destinationAddress: destination,
        destinationPlaceId: _destinationPlaceId,
      ),
    );
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const ClientDrawer(selected: ClientDrawerSection.trips),
      body: Column(
        children: [
          _DestinationAppBar(
            onMenu: () => Scaffold.of(context).openDrawer(),
            onProfileTap: () => AppNavigation.toProfile(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppLayout.marginMobile,
                16.h,
                AppLayout.marginMobile,
                24.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _HeaderSection(),
                  SizedBox(height: 24.h),
                  AddressAutocompleteField(
                    icon: Icons.search,
                    iconColor: AppColors.outline,
                    label: context.l10n.tripDestinationSearchHint,
                    hint: context.l10n.tripDestinationSearchHint,
                    controller: _destinationController,
                    onPlaceSelected: _onDestinationSelected,
                  ),
                  SizedBox(height: 16.h),
                  CurrentLocationField(
                    address: _currentAddress,
                    isLoading: _isLoadingLocation,
                    onRefresh: _requestLocationAccess,
                  ),
                  SizedBox(height: 24.h),
                  _SectionTitle(title: context.l10n.tripDestinationRecentPlaces),
                  SizedBox(height: 8.h),
                  for (final place in TripDestinationData.recentPlaces) ...[
                    _PlaceCard(
                      place: place,
                      onTap: () => _selectPlace(place),
                    ),
                    SizedBox(height: 8.h),
                  ],
                  SizedBox(height: 16.h),
                  _SectionTitle(title: context.l10n.tripDestinationSuggestions),
                  SizedBox(height: 8.h),
                  for (final place in TripDestinationData.favorites) ...[
                    _PlaceCard(
                      place: place,
                      onTap: () => _selectPlace(place),
                    ),
                    SizedBox(height: 8.h),
                  ],
                  SizedBox(height: 8.h),
                  const _SuggestionBanner(),
                  SizedBox(height: 32.h),
                  _SectionTitle(title: context.l10n.tripDestinationExploreMap),
                  SizedBox(height: 12.h),
                  _ExploreMapCard(
                    onOpenMap: () => _openTripConfirm(context),
                  ),
                ],
              ),
            ),
          ),
          AppBottomNav(
            selectedIndex: AppNavIndex.viagens,
            onItemTap: (index) => AppNavigation.onBottomNavTap(context, index),
          ),
        ],
      ),
    );
  }
}

class _DestinationAppBar extends StatelessWidget {
  const _DestinationAppBar({
    required this.onMenu,
    required this.onProfileTap,
  });

  final VoidCallback onMenu;
  final VoidCallback onProfileTap;

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
              onPressed: onMenu,
              icon: Icon(Icons.menu, color: AppColors.primary, size: 24.sp),
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
              size: 32.w,
              fontSize: 12.sp,
              onTap: onProfileTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.homeWhereToday,
          style: GoogleFonts.manrope(
            fontSize: 32.sp,
            fontWeight: FontWeight.w700,
            height: 40 / 32,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          context.l10n.tripDestinationSubtitle,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            height: 24 / 16,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          height: 20 / 14,
          letterSpacing: 0.1,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place, required this.onTap});

  final TripPlace place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              if (place.filledIcon)
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    place.icon,
                    size: 20.sp,
                    color: AppColors.primary,
                  ),
                )
              else
                Icon(place.icon, size: 22.sp, color: AppColors.outline),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.title,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        height: 20 / 14,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      place.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        height: 16 / 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionBanner extends StatelessWidget {
  const _SuggestionBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        height: 112.h,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              TripDestinationData.suggestionBannerImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: AppColors.primary,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.9),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 12.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.tripDestinationTodaySuggestion,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                      color: AppColors.primaryFixed,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    context.l10n.tripDestinationSuggestionTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: Colors.white,
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

class _ExploreMapCard extends StatelessWidget {
  const _ExploreMapCard({required this.onOpenMap});

  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: SizedBox(
        height: 256.h,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              TripDestinationData.exploreMapImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: AppColors.surfaceContainerHigh,
                child: Icon(Icons.map, size: 48.sp),
              ),
            ),
            Positioned(
              top: 16.h,
              right: 16.w,
              child: Column(
                children: [
                  _MapControlButton(icon: Icons.layers),
                  SizedBox(height: 8.h),
                  _MapControlButton(icon: Icons.add),
                  SizedBox(height: 8.h),
                  _MapControlButton(icon: Icons.remove),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 16.h,
              child: Center(
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999.r),
                  elevation: 8,
                  child: InkWell(
                    onTap: onOpenMap,
                    borderRadius: BorderRadius.circular(999.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 14.h,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.map, color: Colors.white, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            context.l10n.tripDestinationViewFullMap,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
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
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(8.r),
      elevation: 2,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Icon(icon, color: AppColors.primary, size: 22.sp),
        ),
      ),
    );
  }
}
