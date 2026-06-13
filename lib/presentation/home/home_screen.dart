import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/services/app_currency_formatter.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/constants/app_assets.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/presentation/widgets/app_bottom_nav.dart';
import 'package:local_ent_280/presentation/widgets/client_drawer.dart';
import 'package:local_ent_280/core/models/trip_route_draft.dart';
import 'package:local_ent_280/core/services/current_location_service.dart';
import 'package:local_ent_280/core/services/places_autocomplete_service.dart';
import 'package:local_ent_280/core/services/location_permission_helper.dart';
import 'package:local_ent_280/presentation/widgets/address_autocomplete_field.dart';
import 'package:local_ent_280/presentation/widgets/current_location_field.dart';
import 'package:local_ent_280/features/auth/data/user_session.dart';
import 'package:local_ent_280/features/balance/data/balance_repository.dart';
import 'package:local_ent_280/presentation/widgets/session_profile_avatar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.balanceRepository});

  final BalanceRepository? balanceRepository;

  static double get _sheetTopRadius => 30.r;
  static double get _gapActionsToSheet => 20.h;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pickupController = TextEditingController();
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
        _pickupController.clear();
      });
      return;
    }

    await _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    // Show cached GPS quickly, then refresh with a live fix.
    final cached = await _locationService.getLastKnownLocation();
    if (mounted && cached != null) {
      setState(() {
        _currentAddress = cached.address;
        _pickupLat = cached.latitude;
        _pickupLng = cached.longitude;
        _pickupController.text = cached.address;
      });
    }

    final location = await _locationService.getCurrentLocation();
    if (!mounted) return;
    setState(() {
      _isLoadingLocation = false;
      _currentAddress = location?.address ?? _currentAddress;
      _pickupLat = location?.latitude ?? _pickupLat;
      _pickupLng = location?.longitude ?? _pickupLng;
      _pickupController.text = location?.address ?? _pickupController.text;
    });
  }

  void _onDestinationSelected(PlacePrediction prediction) {
    _destinationPlaceId = prediction.placeId;
  }

  void _confirmRoute(BuildContext context) {
    final l10n = context.l10n;
    final pickup = _currentAddress?.trim();
    final destination = _destinationController.text.trim();

    if (pickup == null || pickup.isEmpty) {
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
    if (_pickupLat == null || _pickupLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.homeLocationUnavailable)),
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
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const ClientDrawer(selected: ClientDrawerSection.home),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _MapBackground(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _HomeAppBar(),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppLayout.marginMobile,
                ),
                child: _BalanceCard(
                  clientId: UserSession.instance.profile?.uid,
                  balanceRepository:
                      widget.balanceRepository ?? BalanceRepository(),
                ),
              ),
              const Spacer(),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppLayout.marginMobile,
                  ),
                  child: _QuickActionsRow(
                    onPedir: () => AppNavigation.toTripDestination(context),
                    onReservar: () => AppNavigation.toReservations(context),
                    // onAlugar: () => AppNavigation.toVehicleRental(context),
                    onAlugar: () {},
                    onHistorico: () => AppNavigation.toTripHistory(context),
                    onSaldo: () => AppNavigation.toClientBalance(context),
                  ),
                ),
                SizedBox(height: HomeScreen._gapActionsToSheet),
                _TripBottomSheet(
                  currentAddress: _currentAddress,
                  isLoadingLocation: _isLoadingLocation,
                  onRefreshLocation: _requestLocationAccess,
                  destinationController: _destinationController,
                  onDestinationSelected: _onDestinationSelected,
                  onConfirmRoute: () => _confirmRoute(context),
                ),
                AppBottomNav(
                  selectedIndex: AppNavIndex.inicio,
                  onItemTap: (index) =>
                      AppNavigation.onBottomNavTap(context, index),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapBackground extends StatelessWidget {
  const _MapBackground();

  static const String _citySkylineUrl = AppAssets.mapBackgroundImage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          _citySkylineUrl,
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.15),
          width: double.infinity,
          height: double.infinity,
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, error, stackTrace) => ColoredBox(
            color: AppColors.background,
            child: Center(
              child: Icon(
                Icons.location_city,
                size: 64.sp,
                color: AppColors.outline,
              ),
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withValues(alpha: 0.88),
                AppColors.background.withValues(alpha: 0.35),
                Colors.transparent,
                AppColors.surfaceContainerLowest.withValues(alpha: 0.82),
              ],
              stops: const [0.0, 0.22, 0.52, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      bottom: false,
      child: Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
        color: AppColors.surfaceContainerLowest,
        child: Row(
          children: [
            Builder(
              builder: (context) => Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  borderRadius: BorderRadius.circular(999.r),
                  child: SizedBox(
                    width: 40.w,
                    height: 40.h,
                    child: Icon(
                      Icons.menu,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    l10n.appNameLocalTransport,
                    maxLines: 1,
                    style: GoogleFonts.manrope(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      height: 32 / 24,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            SessionProfileAvatar(
              size: 40.w,
              onTap: () => AppNavigation.toProfile(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  _BalanceCard({
    required this.clientId,
    required this.balanceRepository,
  });

  final String? clientId;
  final BalanceRepository balanceRepository;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final uid = clientId;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeAvailableBalance,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    height: 16 / 12,
                    color: AppColors.labelMuted,
                  ),
                ),
                SizedBox(height: 4.h),
                uid == null
                    ? Text(
                        '—',
                        style: GoogleFonts.manrope(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          height: 28 / 20,
                          color: AppColors.primary,
                        ),
                      )
                    : StreamBuilder(
                        stream: balanceRepository.watchClientBalance(uid),
                        builder: (context, snapshot) {
                          final balance = snapshot.data;
                          final label = balance?.formattedAmount ??
                              AppCurrencyFormatter.instance.formatEurMajor(0);
                          return Text(
                            label,
                            style: GoogleFonts.manrope(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              height: 28 / 20,
                              color: AppColors.primary,
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => AppNavigation.toClientBalance(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.onAccent,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: Text(
              l10n.homeTopUp,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.onPedir,
    required this.onReservar,
    required this.onAlugar,
    required this.onHistorico,
    required this.onSaldo,
  });

  final VoidCallback onPedir;
  final VoidCallback onReservar;
  final VoidCallback onAlugar;
  final VoidCallback onHistorico;
  final VoidCallback onSaldo;

  static const _icons = [
    Icons.directions_car,
    Icons.calendar_today,
    Icons.car_rental,
    Icons.history,
    Icons.account_balance_wallet,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final actions = [
      (l10n.homeActionRequest, onPedir),
      (l10n.homeActionBook, onReservar),
      (l10n.homeActionRent, onAlugar),
      (l10n.homeActionHistory, onHistorico),
      (l10n.homeActionBalance, onSaldo),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 8.w;
        final tileWidth = (constraints.maxWidth - gap * 4) / 5;

        return Row(
          children: [
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) SizedBox(width: gap),
              SizedBox(
                width: tileWidth,
                height: tileWidth,
                child: _QuickActionButton(
                  icon: _icons[i],
                  label: actions[i].$1,
                  onTap: actions[i].$2,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.surfaceVariant.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final iconSize = (constraints.maxHeight * 0.48).clamp(28.0, 40.0);
              final labelSize = constraints.maxHeight < 72 ? 11.0 : 12.0;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentSurface,
                      ),
                      child: Icon(
                        icon,
                        color: AppColors.accent,
                        size: iconSize * 0.55,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: labelSize,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        color: AppColors.labelMuted,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TripBottomSheet extends StatefulWidget {
  const _TripBottomSheet({
    required this.currentAddress,
    required this.isLoadingLocation,
    required this.onRefreshLocation,
    required this.destinationController,
    required this.onDestinationSelected,
    required this.onConfirmRoute,
  });

  final String? currentAddress;
  final bool isLoadingLocation;
  final VoidCallback onRefreshLocation;
  final TextEditingController destinationController;
  final ValueChanged<PlacePrediction> onDestinationSelected;
  final VoidCallback onConfirmRoute;

  @override
  State<_TripBottomSheet> createState() => _TripBottomSheetState();
}

class _TripBottomSheetState extends State<_TripBottomSheet> {
  bool _expanded = true;
  double _dragDelta = 0;

  static const _animDuration = Duration(milliseconds: 280);
  static const _animCurve = Curves.easeOutCubic;
  static const _dragThreshold = 40.0;
  static const _velocityThreshold = 250.0;

  void _toggle() => setState(() => _expanded = !_expanded);

  void _onVerticalDragStart(DragStartDetails _) {
    _dragDelta = 0;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    _dragDelta += details.delta.dy;
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    setState(() {
      if (velocity > _velocityThreshold || _dragDelta > _dragThreshold) {
        _expanded = false;
      } else if (velocity < -_velocityThreshold ||
          _dragDelta < -_dragThreshold) {
        _expanded = true;
      }
      _dragDelta = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(HomeScreen._sheetTopRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 24.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            onVerticalDragStart: _onVerticalDragStart,
            onVerticalDragUpdate: _onVerticalDragUpdate,
            onVerticalDragEnd: _onVerticalDragEnd,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.homeWhereToday,
                          style: GoogleFonts.manrope(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            height: 28 / 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        duration: _animDuration,
                        curve: _animCurve,
                        turns: _expanded ? 0 : 0.5,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.labelMuted,
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: _animDuration,
            curve: _animCurve,
            alignment: Alignment.topCenter,
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: _expanded ? 1.0 : 0.0,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: _ExpandedSheetContent(
                  currentAddress: widget.currentAddress,
                  isLoadingLocation: widget.isLoadingLocation,
                  onRefreshLocation: widget.onRefreshLocation,
                  destinationController: widget.destinationController,
                  onDestinationSelected: widget.onDestinationSelected,
                  onConfirmRoute: widget.onConfirmRoute,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandedSheetContent extends StatelessWidget {
  const _ExpandedSheetContent({
    required this.currentAddress,
    required this.isLoadingLocation,
    required this.onRefreshLocation,
    required this.destinationController,
    required this.onDestinationSelected,
    required this.onConfirmRoute,
  });

  final String? currentAddress;
  final bool isLoadingLocation;
  final VoidCallback onRefreshLocation;
  final TextEditingController destinationController;
  final ValueChanged<PlacePrediction> onDestinationSelected;
  final VoidCallback onConfirmRoute;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 8.h),
        Stack(
          children: [
            Positioned(
              left: 19,
              top: 42,
              child: Container(
                width: 2.w,
                height: 32.h,
                color: AppColors.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            Column(
              children: [
                CurrentLocationField(
                  address: currentAddress,
                  isLoading: isLoadingLocation,
                  onRefresh: onRefreshLocation,
                ),
                SizedBox(height: 12.h),
                AddressAutocompleteField(
                  icon: Icons.location_on,
                  iconColor: AppColors.outline,
                  label: l10n.homeDestination,
                  controller: destinationController,
                  hint: l10n.homeDestinationHint,
                  onPlaceSelected: onDestinationSelected,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 48.h,
          child: ElevatedButton(
            onPressed: onConfirmRoute,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.onAccent,
              elevation: 4,
              shadowColor: AppColors.accent.withValues(alpha: 0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              l10n.homeConfirmRoute,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

