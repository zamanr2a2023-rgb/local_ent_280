import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/constants/app_assets.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/presentation/widgets/app_bottom_nav.dart';

/// Pesquisa de Aluguer de Veículos — `roles/details.md` mockup.
class VehicleRentalScreen extends StatefulWidget {
  const VehicleRentalScreen({super.key});

  @override
  State<VehicleRentalScreen> createState() => _VehicleRentalScreenState();
}

class _VehicleRentalScreenState extends State<VehicleRentalScreen> {
  static const _driverAgeOptions = [
    '18 - 25 anos',
    '26 - 65 anos',
    '+ 65 anos',
  ];

  final _pickupController = TextEditingController(text: 'Aeroporto de Lisboa, PT');
  final _dropoffController = TextEditingController(text: 'Mesmo local de recolha');

  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _rangeStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _rangeEnd = DateTime(DateTime.now().year, DateTime.now().month, 6);

  String _driverAge = _driverAgeOptions[1];
  bool _premiumOnly = true;

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  void _shiftMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  void _onDayTap(DateTime day) {
    setState(() {
      final sameDay = _rangeStart.year == day.year &&
          _rangeStart.month == day.month &&
          _rangeStart.day == day.day;
      final hasRange = _rangeStart.day != _rangeEnd.day ||
          _rangeStart.month != _rangeEnd.month;

      if (sameDay && hasRange || sameDay && !hasRange) {
        _rangeStart = day;
        _rangeEnd = day;
        return;
      }
      if (day.isBefore(_rangeStart)) {
        _rangeEnd = _rangeStart;
        _rangeStart = day;
      } else {
        _rangeEnd = day;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _RentalAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppLayout.marginMobile,
                      32.h,
                      AppLayout.marginMobile,
                      24.h,
                    ),
                    child: const _HeroHeader(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppLayout.marginMobile,
                    ),
                    child: _SearchFormCard(
                      pickupController: _pickupController,
                      dropoffController: _dropoffController,
                      visibleMonth: _visibleMonth,
                      rangeStart: _rangeStart,
                      rangeEnd: _rangeEnd,
                      driverAge: _driverAge,
                      premiumOnly: _premiumOnly,
                      onMonthShift: _shiftMonth,
                      onDayTap: _onDayTap,
                      onDriverAgeChanged: (v) => setState(() => _driverAge = v),
                      onPremiumChanged: (v) => setState(() => _premiumOnly = v),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppLayout.marginMobile,
                    ),
                    child: const _FleetMapPreview(),
                  ),
                ],
              ),
            ),
          ),
          AppBottomNav(
            selectedIndex: AppNavIndex.reservas,
            onItemTap: (index) => AppNavigation.onBottomNavTap(context, index),
          ),
        ],
      ),
    );
  }
}

class _RentalAppBar extends StatelessWidget {
  const _RentalAppBar();

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
              onPressed: () {},
              icon: Icon(Icons.menu, color: AppColors.primary, size: 24.sp),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                'Mobilidade Premium',
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
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceVariant,
              ),
              child: ClipOval(
                child: Image.network(
                  AppAssets.vehicleRentalProfileAvatarImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 18.sp,
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

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aluguer de Veículos',
          style: GoogleFonts.manrope(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            height: 36 / 28,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Encontre o parceiro perfeito para a sua próxima viagem.',
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

class _SearchFormCard extends StatelessWidget {
  const _SearchFormCard({
    required this.pickupController,
    required this.dropoffController,
    required this.visibleMonth,
    required this.rangeStart,
    required this.rangeEnd,
    required this.driverAge,
    required this.premiumOnly,
    required this.onMonthShift,
    required this.onDayTap,
    required this.onDriverAgeChanged,
    required this.onPremiumChanged,
  });

  final TextEditingController pickupController;
  final TextEditingController dropoffController;
  final DateTime visibleMonth;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final String driverAge;
  final bool premiumOnly;
  final ValueChanged<int> onMonthShift;
  final ValueChanged<DateTime> onDayTap;
  final ValueChanged<String> onDriverAgeChanged;
  final ValueChanged<bool> onPremiumChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LocationField(
            label: 'Local de Recolha',
            icon: Icons.location_on_outlined,
            controller: pickupController,
            hint: 'Aeroporto de Lisboa, PT',
          ),
          SizedBox(height: 16.h),
          _LocationField(
            label: 'Local de Entrega',
            icon: Icons.trip_origin,
            controller: dropoffController,
            hint: 'Mesmo local de recolha',
          ),
          SizedBox(height: 16.h),
          _DateCalendarSection(
            visibleMonth: visibleMonth,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd,
            onMonthShift: onMonthShift,
            onDayTap: onDayTap,
          ),
          SizedBox(height: 16.h),
          _DriverAgeSection(
            value: driverAge,
            onChanged: onDriverAgeChanged,
          ),
          SizedBox(height: 16.h),
          _PremiumToggleRow(
            value: premiumOnly,
            onChanged: onPremiumChanged,
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 56.h,
            child: FilledButton.icon(
              onPressed: () => AppNavigation.toVehicleSearchResults(context),
              icon: Icon(Icons.search, size: 22.sp, color: AppColors.onSecondary),
              label: Text(
                'Pesquisar Veículos Disponíveis',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  color: AppColors.onSecondary,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.onSecondary,
                elevation: 4,
                shadowColor: AppColors.secondary.withValues(alpha: 0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.hint,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 20 / 14,
              letterSpacing: 0.1,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.outline, size: 22.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    height: 24 / 16,
                    color: AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 16.sp,
                      color: AppColors.outlineVariant,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateCalendarSection extends StatelessWidget {
  const _DateCalendarSection({
    required this.visibleMonth,
    required this.rangeStart,
    required this.rangeEnd,
    required this.onMonthShift,
    required this.onDayTap,
  });

  final DateTime visibleMonth;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final ValueChanged<int> onMonthShift;
  final ValueChanged<DateTime> onDayTap;

  static const _weekdays = ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Seleção de Datas',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onMonthShift(-1),
                icon: Icon(
                  Icons.chevron_left,
                  color: AppColors.onSurfaceVariant,
                  size: 22.sp,
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
              ),
              IconButton(
                onPressed: () => onMonthShift(1),
                icon: Icon(
                  Icons.chevron_right,
                  color: AppColors.onSurfaceVariant,
                  size: 22.sp,
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: _weekdays
                .map(
                  (d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        height: 16 / 12,
                        color: AppColors.outline,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 8.h),
          _CalendarGrid(
            visibleMonth: visibleMonth,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd,
            onDayTap: onDayTap,
          ),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.visibleMonth,
    required this.rangeStart,
    required this.rangeEnd,
    required this.onDayTap,
  });

  final DateTime visibleMonth;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(visibleMonth.year, visibleMonth.month);
    final daysInMonth = DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
    final startWeekday = firstOfMonth.weekday % 7;
    final leadingDays = DateTime(visibleMonth.year, visibleMonth.month, 0).day;

    final cells = <Widget>[];

    for (var i = 0; i < startWeekday; i++) {
      final day = leadingDays - startWeekday + i + 1;
      cells.add(_CalendarDayCell(
        label: '$day',
        state: _DayCellState.outOfMonth,
        onTap: null,
      ));
    }

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(visibleMonth.year, visibleMonth.month, day);
      cells.add(_CalendarDayCell(
        label: '$day',
        state: _dayState(date, rangeStart, rangeEnd),
        onTap: () => onDayTap(date),
      ));
    }

    while (cells.length % 7 != 0) {
      cells.add(const _CalendarDayCell(label: '', state: _DayCellState.empty));
    }

    return Column(
      children: [
        for (var row = 0; row < cells.length; row += 7)
          Padding(
            padding: EdgeInsets.only(bottom: row + 7 < cells.length ? 4.h : 0),
            child: Row(
              children: cells
                  .sublist(row, row + 7)
                  .map((c) => Expanded(child: c))
                  .toList(),
            ),
          ),
      ],
    );
  }

  _DayCellState _dayState(DateTime day, DateTime start, DateTime end) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    final d = DateTime(day.year, day.month, day.day);

    if (d == s && d == e) return _DayCellState.rangeStartEnd;
    if (d == s) return _DayCellState.rangeStart;
    if (d == e) return _DayCellState.rangeEnd;
    if (d.isAfter(s) && d.isBefore(e)) return _DayCellState.inRange;
    return _DayCellState.normal;
  }
}

enum _DayCellState {
  empty,
  outOfMonth,
  normal,
  inRange,
  rangeStart,
  rangeEnd,
  rangeStartEnd,
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.label,
    required this.state,
    this.onTap,
  });

  final String label;
  final _DayCellState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (state == _DayCellState.empty) {
      return SizedBox(height: 36.h);
    }

    Color? bg;
    BorderRadius? radius;
    Color textColor = AppColors.onSurface;
    FontWeight weight = FontWeight.w400;

    switch (state) {
      case _DayCellState.outOfMonth:
        textColor = AppColors.outlineVariant;
      case _DayCellState.inRange:
        bg = AppColors.secondaryContainer.withValues(alpha: 0.2);
        textColor = AppColors.onSurfaceVariant;
      case _DayCellState.rangeStart:
        bg = AppColors.secondaryContainer;
        textColor = AppColors.onSecondaryContainer;
        weight = FontWeight.w700;
        radius = BorderRadius.horizontal(left: Radius.circular(999.r));
      case _DayCellState.rangeEnd:
        bg = AppColors.secondaryContainer;
        textColor = AppColors.onSecondaryContainer;
        weight = FontWeight.w700;
        radius = BorderRadius.horizontal(right: Radius.circular(999.r));
      case _DayCellState.rangeStartEnd:
        bg = AppColors.secondaryContainer;
        textColor = AppColors.onSecondaryContainer;
        weight = FontWeight.w700;
        radius = BorderRadius.circular(999.r);
      case _DayCellState.normal:
      case _DayCellState.empty:
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: radius,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: weight,
            height: 16 / 12,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _DriverAgeSection extends StatelessWidget {
  const _DriverAgeSection({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Idade do Condutor',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 20 / 14,
              letterSpacing: 0.1,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
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
                  fontWeight: FontWeight.w400,
                  color: AppColors.onSurface,
                ),
                items: _VehicleRentalScreenState._driverAgeOptions
                    .map(
                      (o) => DropdownMenuItem(value: o, child: Text(o)),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Taxas adicionais podem ser aplicadas para condutores fora do intervalo padrão.',
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              height: 1.3,
              color: AppColors.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumToggleRow extends StatelessWidget {
  const _PremiumToggleRow({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Only',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Mostrar apenas frota de luxo',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.secondaryContainer,
            activeThumbColor: Colors.white,
            inactiveTrackColor: AppColors.surfaceContainer,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class _FleetMapPreview extends StatelessWidget {
  const _FleetMapPreview();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        height: 192.h,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.surfaceContainer),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              AppAssets.vehicleRentalMapImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: AppColors.surfaceContainerHigh,
                child: Icon(Icons.map, size: 48.sp, color: AppColors.outline),
              ),
            ),
            ColoredBox(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.35),
            ),
            Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(999.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          blurRadius: 16.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map, color: AppColors.secondary, size: 22.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Ver frota no mapa',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            height: 20 / 14,
                            letterSpacing: 0.1,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
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
