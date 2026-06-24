import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/admin/domain/entities/admin_user.dart';
import 'package:local_transport/features/admin/presentation/widgets/admin_user_form_sheet.dart';
import 'package:local_transport/features/auth/domain/entities/profile_role.dart';
import 'package:local_transport/l10n/app_localizations.dart';

void main() {
  testWidgets('submits a new password while editing a user', (tester) async {
    AdminUserFormPayload? submittedPayload;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt', 'PT'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AdminUserFormSheet(
            mode: AdminUserFormMode.edit,
            user: const AdminUser(
              id: 'user-1',
              name: 'Cliente Teste',
              email: 'cliente@example.com',
              phone: '912345678',
              role: ProfileRole.client,
              isActive: true,
            ),
            isSubmitting: false,
            errorMessage: null,
            onSubmit: (payload) async {
              submittedPayload = payload;
              return true;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Nova palavra-passe'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(2), 'NovaPass123');
    await tester.ensureVisible(find.text('Guardar alterações'));
    await tester.tap(find.text('Guardar alterações'));
    await tester.pumpAndSettle();

    expect(submittedPayload?.password, 'NovaPass123');
  });
}
