import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/constants/app_assets.dart';
import 'package:local_ent_280/core/data/trip_confirm_data.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';

/// Confirmação de viagem com mapa — `roles/details.md`.
class TripConfirmScreen extends StatefulWidget {
  const TripConfirmScreen({super.key});

  @override
  State<TripConfirmScreen> createState() => _TripConfirmScreenState();
}

class _TripConfirmScreenState extends State<TripConfirmScreen> {
  String _selectedTransportId = TripConfirmData.transportOptions.first.id;

  double get _totalPrice {
    return TripConfirmData.transportOptions
        .firstWhere((o) => o.id == _selectedTransportId)
        .price;
  }

  String get _formattedTotal =>
      '${_totalPrice.toStringAsFixed(2).replaceAll('.', ',')}€';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final topInset = MediaQuery.paddingOf(context).top + 56.h;
          // Mapa visível acima do bottom sheet (~44% do ecrã).
          final mapAreaBottom = constraints.maxHeight * 0.44;

          return Stack(
            fit: StackFit.expand,
            children: [
              _MapLayer(mapTop: topInset, mapBottom: mapAreaBottom),
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
                    _MapFabButton(icon: Icons.my_location, onTap: () {}),
                    SizedBox(height: 8.h),
                    _MapFabButton(icon: Icons.layers, onTap: () {}),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _TripDetailsSheet(
                  selectedTransportId: _selectedTransportId,
                  totalFormatted: _formattedTotal,
                  onTransportSelected: (id) =>
                      setState(() => _selectedTransportId = id),
                  onConfirm: () => AppNavigation.toDriverSearch(context),
                ),
              ),
            ],
          );
        },
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
                'Local Transport',
                style: GoogleFonts.manrope(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  height: 32 / 24,
                  color: AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surfaceContainerHigh,
                  width: 2.w,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  TripConfirmData.profileAvatarImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.person, size: 20.sp, color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mapa Lisboa com rota e pins já desenhados no asset — sem overlays extra.
class _MapLayer extends StatelessWidget {
  const _MapLayer({required this.mapTop, required this.mapBottom});

  final double mapTop;
  final double mapBottom;

  @override
  Widget build(BuildContext context) {
    final mapHeight = mapBottom - mapTop;
    if (mapHeight <= 0) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: mapTop,
      left: 0,
      right: 0,
      height: mapHeight,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              AppAssets.tripConfirmMapImage,
              fit: BoxFit.cover,
              alignment: const Alignment(0.05, -0.05),
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: AppColors.surfaceContainer,
                child: Center(
                  child: Icon(Icons.map, size: 64.sp, color: AppColors.outline),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 20.h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.background.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 56.h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.surfaceContainerLowest,
                      AppColors.surfaceContainerLowest.withValues(alpha: 0),
                    ],
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
    required this.selectedTransportId,
    required this.totalFormatted,
    required this.onTransportSelected,
    required this.onConfirm,
  });

  final String selectedTransportId;
  final String totalFormatted;
  final ValueChanged<String> onTransportSelected;
  final VoidCallback onConfirm;

  static double get _sheetRadius => 24.r;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(_sheetRadius)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        AppLayout.marginMobile,
        8.h,
        AppLayout.marginMobile,
        24.h + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const _RouteSection(),
            SizedBox(height: 24.h),
            const _TripStatsRow(),
            SizedBox(height: 24.h),
            Text(
              'Tipo de Transporte',
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
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: TripConfirmData.transportOptions.length,
                separatorBuilder: (context, index) => SizedBox(width: 16.w),
                itemBuilder: (context, index) {
                  final option = TripConfirmData.transportOptions[index];
                  return _TransportOptionCard(
                    option: option,
                    selected: option.id == selectedTransportId,
                    onTap: () => onTransportSelected(option.id),
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
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
                onPressed: onConfirm,
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
                    Text(
                      'Confirmar viagem',
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
    );
  }
}

class _RouteSection extends StatelessWidget {
  const _RouteSection();

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
                    'PONTO DE RECOLHA',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    TripConfirmData.pickupLabel,
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
                    'DESTINO FINAL',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    TripConfirmData.destinationLabel,
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
  const _TripStatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.straighten,
            iconColor: AppColors.primaryContainer,
            iconBgColor: AppColors.primaryContainer.withValues(alpha: 0.1),
            label: 'Distância',
            value: TripConfirmData.distance,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _StatCard(
            icon: Icons.schedule,
            iconColor: AppColors.secondary,
            iconBgColor: AppColors.secondaryContainer.withValues(alpha: 0.1),
            label: 'Duração',
            value: TripConfirmData.duration,
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
    required this.selected,
    required this.onTap,
  });

  final TransportOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final priceText =
        '${option.price.toStringAsFixed(2).replaceAll('.', ',')}€';

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
              option.label,
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
