import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/presentation/splash/splash_screen.dart';

void main() {
  testWidgets('Splash screen renders without error', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      AppScreenUtil.testWrap(const SplashScreen()),
    );
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
