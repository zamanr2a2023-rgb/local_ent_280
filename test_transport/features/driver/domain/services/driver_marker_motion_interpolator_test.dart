import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/driver/domain/entities/driver_location.dart';
import 'package:local_transport/features/driver/domain/services/driver_marker_motion_interpolator.dart';

void main() {
  const interpolator = DriverMarkerMotionInterpolator();

  test('animates short city-distance updates', () {
    final from = const DriverLocation(latitude: 38.7169, longitude: -9.1399);
    final to = const DriverLocation(latitude: 38.7170, longitude: -9.1397);

    expect(interpolator.shouldAnimate(from: from, to: to), isTrue);
  });

  test('animates large updates so recovered locations do not jump', () {
    final from = const DriverLocation(latitude: 38.7169, longitude: -9.1399);
    final to = const DriverLocation(latitude: 38.7269, longitude: -9.1299);

    expect(interpolator.shouldAnimate(from: from, to: to), isTrue);
  });

  test('allows callers to cap animated distance when needed', () {
    const cappedInterpolator = DriverMarkerMotionInterpolator(
      maxAnimatedDistanceMeters: 220,
    );
    final from = const DriverLocation(latitude: 38.7169, longitude: -9.1399);
    final to = const DriverLocation(latitude: 38.7269, longitude: -9.1299);

    expect(cappedInterpolator.shouldAnimate(from: from, to: to), isFalse);
  });

  test('wraps heading across north when interpolating', () {
    final from = const DriverLocation(
      latitude: 38.7169,
      longitude: -9.1399,
      heading: 350,
    );
    final to = const DriverLocation(
      latitude: 38.7170,
      longitude: -9.1397,
      heading: 10,
    );

    final midpoint = interpolator.interpolate(
      from: from,
      to: to,
      progress: 0.5,
    );

    expect(midpoint.heading, isNotNull);
    expect(midpoint.heading, closeTo(0, 0.001));
  });

  test('clamps animation duration inside UX bounds', () {
    final from = const DriverLocation(latitude: 38.7169, longitude: -9.1399);
    final to = const DriverLocation(latitude: 38.7170, longitude: -9.1397);

    final duration = interpolator.recommendDuration(from: from, to: to);

    expect(duration, greaterThanOrEqualTo(const Duration(milliseconds: 350)));
    expect(duration, lessThanOrEqualTo(const Duration(milliseconds: 2200)));
  });
}
