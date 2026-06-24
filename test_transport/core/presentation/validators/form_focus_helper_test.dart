import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/presentation/validators/form_focus_helper.dart';

void main() {
  testWidgets(
    'focusFirstInvalidOnSubmit só altera foco no submit',
    (tester) async {
      final formKey = GlobalKey<FormState>();
      final firstFieldKey = GlobalKey<FormFieldState<String>>();
      final secondFieldKey = GlobalKey<FormFieldState<String>>();
      final firstFocus = FocusNode();
      final secondFocus = FocusNode();
      final firstController = TextEditingController();
      final secondController = TextEditingController();
      late BuildContext screenContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                screenContext = context;
                return SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        TextFormField(
                          key: firstFieldKey,
                          focusNode: firstFocus,
                          controller: firstController,
                          validator: (value) =>
                              (value ?? '').trim().isEmpty ? 'required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          key: secondFieldKey,
                          focusNode: secondFocus,
                          controller: secondController,
                          validator: (value) =>
                              (value ?? '').trim().isEmpty ? 'required' : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextFormField).at(1));
      await tester.pump();
      expect(secondFocus.hasFocus, isTrue);

      await tester.enterText(find.byType(TextFormField).at(1), 'ok');
      await tester.pump();
      expect(secondFocus.hasFocus, isTrue);

      final result = await FormFocusHelper.focusFirstInvalidOnSubmit(
        context: screenContext,
        formKey: formKey,
        orderedTargets: <FormFieldFocusTarget>[
          FormFieldFocusTarget(fieldKey: firstFieldKey, focusNode: firstFocus),
          FormFieldFocusTarget(
            fieldKey: secondFieldKey,
            focusNode: secondFocus,
          ),
        ],
      );
      await tester.pumpAndSettle();

      expect(result, isFalse);
      expect(firstFocus.hasFocus, isTrue);

      firstFocus.dispose();
      secondFocus.dispose();
      firstController.dispose();
      secondController.dispose();
    },
  );

  testWidgets('focusFirstInvalidOnSubmit retorna true quando form é válido', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final firstFieldKey = GlobalKey<FormFieldState<String>>();
    final firstFocus = FocusNode();
    final firstController = TextEditingController(text: 'ok');
    late BuildContext screenContext;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              screenContext = context;
              return Form(
                key: formKey,
                child: TextFormField(
                  key: firstFieldKey,
                  focusNode: firstFocus,
                  controller: firstController,
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'required' : null,
                ),
              );
            },
          ),
        ),
      ),
    );

    final result = await FormFocusHelper.focusFirstInvalidOnSubmit(
      context: screenContext,
      formKey: formKey,
      orderedTargets: <FormFieldFocusTarget>[
        FormFieldFocusTarget(fieldKey: firstFieldKey, focusNode: firstFocus),
      ],
    );

    expect(result, isTrue);

    firstFocus.dispose();
    firstController.dispose();
  });
}
