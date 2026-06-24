import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/services/places_autocomplete_service.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';

/// Address field with Google Places autocomplete suggestions.
class AddressAutocompleteField extends StatefulWidget {
  const AddressAutocompleteField({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.controller,
    this.labelColor,
    this.hint,
    this.placesService,
    this.onPlaceSelected,
    this.biasLatitude,
    this.biasLongitude,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final String? hint;
  final TextEditingController controller;
  final PlacesAutocompleteService? placesService;
  final ValueChanged<PlacePrediction>? onPlaceSelected;
  final double? biasLatitude;
  final double? biasLongitude;

  @override
  State<AddressAutocompleteField> createState() =>
      _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  late final PlacesAutocompleteService _placesService =
      widget.placesService ?? PlacesAutocompleteService();

  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  List<PlacePrediction> _suggestions = [];
  bool _isLoading = false;
  bool _suppressSearch = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      setState(() => _suggestions = []);
    } else if (widget.controller.text.trim().isNotEmpty) {
      _scheduleSearch(widget.controller.text);
    }
  }

  void _onTextChanged() {
    if (_suppressSearch) return;
    _scheduleSearch(widget.controller.text);
  }

  void _scheduleSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      _fetchSuggestions(value);
    });
  }

  Future<void> _fetchSuggestions(String value) async {
    if (!_focusNode.hasFocus) return;

    final query = value.trim();
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
      }
      return;
    }

    setState(() => _isLoading = true);
    final results = await _placesService.search(
      query,
      biasLatitude: widget.biasLatitude,
      biasLongitude: widget.biasLongitude,
    );
    if (!mounted || !_focusNode.hasFocus) return;

    setState(() {
      _suggestions = results.take(6).toList();
      _isLoading = false;
    });
  }

  void _selectSuggestion(PlacePrediction prediction) {
    _suppressSearch = true;
    widget.controller.text = prediction.description;
    widget.controller.selection = TextSelection.collapsed(
      offset: prediction.description.length,
    );
    _suppressSearch = false;
    setState(() => _suggestions = []);
    _focusNode.unfocus();
    widget.onPlaceSelected?.call(prediction);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(widget.icon, color: widget.iconColor, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        color: widget.labelColor ?? AppColors.labelMuted,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.25,
                        color: AppColors.onSurface,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: widget.hint,
                        hintStyle: GoogleFonts.inter(
                          fontSize: 15.sp,
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 4.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 12.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 4.h),
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: AppColors.outlineVariant.withValues(alpha: 0.35),
              ),
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return InkWell(
                  onTap: () => _selectSuggestion(suggestion),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 18.sp,
                          color: AppColors.accent,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            suggestion.description,
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
