import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/features/rental/data/rental_vehicle_repository.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/presentation/widgets/app_bottom_nav.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';

/// Resultados da pesquisa de veículos — `roles/details.md`.
class VehicleSearchResultsScreen extends StatefulWidget {
  const VehicleSearchResultsScreen({super.key, this.repository});

  final RentalVehicleRepository? repository;

  @override
  State<VehicleSearchResultsScreen> createState() =>
      _VehicleSearchResultsScreenState();
}

class _VehicleSearchResultsScreenState extends State<VehicleSearchResultsScreen> {
  late final RentalVehicleRepository _repository;
  String _carType = 'Todos os tipos';
  String _maxPrice = 'Qualquer preço';
  String _transmission = 'Todas';

  static const _carTypes = [
    'Todos os tipos',
    'Sedan',
    'SUV',
    'Executivo',
    'Elétrico',
  ];
  static const _maxPrices = [
    'Qualquer preço',
    'Até 50€/dia',
    'Até 100€/dia',
    'Até 200€/dia',
  ];
  static const _transmissions = ['Todas', 'Automático', 'Manual'];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? RentalVehicleRepository();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _ResultsAppBar(),
          Expanded(
            child: StreamBuilder<List<RentalVehicleRecord>>(
              stream: _repository.watchActiveVehicles(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppLayout.marginMobile),
                      child: Text(
                        context.l10n.rentalLoadError,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }

                final allVehicles = snapshot.data ?? const [];
                final filtered = RentalVehicleRepository.applyFilters(
                  allVehicles,
                  carType: _carType,
                  maxPrice: _maxPrice,
                  transmission: _transmission,
                );
                final premium =
                    filtered.where((vehicle) => vehicle.isPremium).toList();
                final standard =
                    filtered.where((vehicle) => !vehicle.isPremium).toList();

                return SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppLayout.marginMobile,
                          24.h,
                          AppLayout.marginMobile,
                          0,
                        ),
                        child: _FilterCard(
                          carType: _carType,
                          maxPrice: _maxPrice,
                          transmission: _transmission,
                          carTypes: _carTypes,
                          maxPrices: _maxPrices,
                          transmissions: _transmissions,
                          onCarTypeChanged: (v) => setState(() => _carType = v),
                          onMaxPriceChanged: (v) => setState(() => _maxPrice = v),
                          onTransmissionChanged: (v) =>
                              setState(() => _transmission = v),
                        ),
                      ),
                      SizedBox(height: 32.h),
                      if (filtered.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppLayout.marginMobile,
                            vertical: 32.h,
                          ),
                          child: Text(
                            context.l10n.rentalNoVehicles,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        )
                      else ...[
                        if (premium.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppLayout.marginMobile,
                            ),
                            child: _PremiumSection(
                              vehicles: premium,
                              onViewDetails: (id) =>
                                  AppNavigation.toVehicleDetail(context, vehicleId: id),
                            ),
                          ),
                        if (premium.isNotEmpty && standard.isNotEmpty)
                          SizedBox(height: 32.h),
                        if (standard.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppLayout.marginMobile,
                            ),
                            child: _StandardSection(
                              vehicles: standard,
                              onViewDetails: (id) =>
                                  AppNavigation.toVehicleDetail(context, vehicleId: id),
                            ),
                          ),
                      ],
                      SizedBox(height: 16.h),
                    ],
                  ),
                );
              },
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

class _ResultsAppBar extends StatelessWidget {
  const _ResultsAppBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 56.h,
        color: AppColors.background,
        padding: EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
        alignment: Alignment.centerLeft,
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
    );
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.carType,
    required this.maxPrice,
    required this.transmission,
    required this.carTypes,
    required this.maxPrices,
    required this.transmissions,
    required this.onCarTypeChanged,
    required this.onMaxPriceChanged,
    required this.onTransmissionChanged,
  });

  final String carType;
  final String maxPrice;
  final String transmission;
  final List<String> carTypes;
  final List<String> maxPrices;
  final List<String> transmissions;
  final ValueChanged<String> onCarTypeChanged;
  final ValueChanged<String> onMaxPriceChanged;
  final ValueChanged<String> onTransmissionChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FilterDropdown(
            label: context.l10n.rentalCarType,
            value: carType,
            items: carTypes,
            onChanged: onCarTypeChanged,
          ),
          SizedBox(height: 16.h),
          _FilterDropdown(
            label: context.l10n.rentalMaxPrice,
            value: maxPrice,
            items: maxPrices,
            onChanged: onMaxPriceChanged,
          ),
          SizedBox(height: 16.h),
          _FilterDropdown(
            label: context.l10n.rentalTransmission,
            value: transmission,
            items: transmissions,
            onChanged: onTransmissionChanged,
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 48.h,
            child: FilledButton.icon(
              onPressed: () {},
              icon: Icon(Icons.filter_list, size: 22.sp),
              label: Text(
                context.l10n.rentalFilter,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.onSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            height: 20 / 14,
            letterSpacing: 0.1,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.all(color: AppColors.outlineVariant),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.expand_more, color: AppColors.onSurface, size: 22.sp),
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                color: AppColors.onSurface,
              ),
              items: items
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _PremiumSection extends StatelessWidget {
  const _PremiumSection({
    required this.vehicles,
    required this.onViewDetails,
  });

  final List<RentalVehicleRecord> vehicles;
  final ValueChanged<String> onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.rentalPremiumHighlights,
                style: GoogleFonts.manrope(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  height: 28 / 20,
                  color: AppColors.primary,
                ),
              ),
            ),
            Text(
              context.l10n.rentalResultsFound('${vehicles.length}'),
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        for (var i = 0; i < vehicles.length; i++) ...[
          if (i > 0) SizedBox(height: 16.h),
          _PremiumVehicleCard(
            vehicle: vehicles[i],
            onViewDetails: () => onViewDetails(vehicles[i].id),
          ),
        ],
      ],
    );
  }
}

class _PremiumVehicleCard extends StatelessWidget {
  const _PremiumVehicleCard({
    required this.vehicle,
    required this.onViewDetails,
  });

  final RentalVehicleRecord vehicle;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.secondaryContainer, width: 2.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Image.network(
                vehicle.imageUrl,
                height: 192.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => ColoredBox(
                  color: AppColors.surfaceContainerHigh,
                  child: SizedBox(
                    height: 192.h,
                    child: Icon(Icons.directions_car, size: 48.sp),
                  ),
                ),
              ),
              Positioned(
                top: 16.h,
                left: 16.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 16.sp,
                        color: AppColors.onSecondaryContainer,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        context.l10n.rentalPremiumChoice,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        vehicle.name,
                        style: GoogleFonts.manrope(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          height: 28 / 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${vehicle.pricePerDay}€',
                            style: GoogleFonts.manrope(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          TextSpan(
                            text: '/dia',
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _VehicleSpecsRow(vehicle: vehicle),
                SizedBox(height: 16.h),
                SizedBox(
                  height: 48.h,
                  child: FilledButton(
                    onPressed: onViewDetails,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      context.l10n.details,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
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

class _StandardSection extends StatelessWidget {
  const _StandardSection({
    required this.vehicles,
    required this.onViewDetails,
  });

  final List<RentalVehicleRecord> vehicles;
  final ValueChanged<String> onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.rentalAllCars,
          style: GoogleFonts.manrope(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            height: 28 / 20,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 16.h),
        for (var i = 0; i < vehicles.length; i++) ...[
          if (i > 0) SizedBox(height: 16.h),
          _StandardVehicleCard(
            vehicle: vehicles[i],
            onViewDetails: () => onViewDetails(vehicles[i].id),
          ),
        ],
      ],
    );
  }
}

class _StandardVehicleCard extends StatelessWidget {
  const _StandardVehicleCard({
    required this.vehicle,
    required this.onViewDetails,
  });

  final RentalVehicleRecord vehicle;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.network(
            vehicle.imageUrl,
            height: 192.h,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => ColoredBox(
              color: AppColors.surfaceContainerHigh,
              child: SizedBox(
                height: 192.h,
                child: Icon(Icons.directions_car, size: 48.sp),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        vehicle.name,
                        style: GoogleFonts.manrope(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          height: 28 / 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${vehicle.pricePerDay}€',
                          style: GoogleFonts.manrope(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '/dia',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _VehicleSpecsRow(vehicle: vehicle, compact: true),
                SizedBox(height: 16.h),
                SizedBox(
                  height: 44.h,
                  child: OutlinedButton(
                    onPressed: onViewDetails,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.secondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      context.l10n.details,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
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

class _VehicleSpecsRow extends StatelessWidget {
  const _VehicleSpecsRow({required this.vehicle, this.compact = false});

  final RentalVehicleRecord vehicle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 18.sp : 20.sp;
    final fontSize = compact ? 12.sp : 14.sp;

    final specs = <Widget>[
      _SpecChip(
        icon: Icons.person_outline,
        label: '${vehicle.seats} Lugares',
        iconSize: iconSize,
        fontSize: fontSize,
      ),
      _SpecChip(
        icon: Icons.work_outline,
        label: '${vehicle.bags} ${vehicle.bags == 1 ? 'Mala' : 'Malas'}',
        iconSize: iconSize,
        fontSize: fontSize,
      ),
      if (vehicle.hasAc)
        _SpecChip(
          icon: Icons.ac_unit,
          label: 'AC',
          iconSize: iconSize,
          fontSize: fontSize,
        ),
      _SpecChip(
        icon: vehicle.isElectric ? Icons.bolt : Icons.settings_input_component,
        label: vehicle.isElectric ? 'Elétrico' : vehicle.transmissionLabel,
        iconSize: iconSize,
        fontSize: fontSize,
      ),
    ];

    if (compact) {
      return Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: specs,
      );
    }

    return Wrap(
      spacing: 16.w,
      runSpacing: 8.h,
      children: specs,
    );
  }
}

class _SpecChip extends StatelessWidget {
  const _SpecChip({
    required this.icon,
    required this.label,
    required this.iconSize,
    required this.fontSize,
  });

  final IconData icon;
  final String label;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: AppColors.onSurfaceVariant),
        SizedBox(width: 4.w),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
