import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_trendy/features/auth/presentation/widgets/auth_form_field.dart';

void main() {
  group('AuthFormField Widget Tests', () {
    testWidgets('renders correctly with given labelText', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthFormField(
              controller: TextEditingController(),
              labelText: 'Test Label',
            ),
          ),
        ),
      );

      // Verify that the labelText is displayed.
      expect(find.text('Test Label'), findsOneWidget);
      // Verify that a TextFormField is rendered.
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('obscures text when obscureText is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthFormField(
              controller: TextEditingController(),
              labelText: 'Password',
              obscureText: true,
            ),
          ),
        ),
      );

      // Find the underlying TextField widget, which holds the obscureText property.
      final textField = tester.widget<TextField>(find.byType(TextField));
      // Verify that the obscureText property is set to true on the TextField.
      expect(textField.obscureText, isTrue);
    });

    testWidgets('does not obscure text when obscureText is false or default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthFormField(
              controller: TextEditingController(),
              labelText: 'Email',
            ),
          ),
        ),
      );

      // Find the underlying TextField widget.
      final textField = tester.widget<TextField>(find.byType(TextField));
      // Verify that the obscureText property is set to false (the default) on the TextField.
      expect(textField.obscureText, isFalse);
    });

    testWidgets('shows validation error when validator returns a message', (
      WidgetTester tester,
    ) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: AuthFormField(
                controller: TextEditingController(),
                labelText: 'Required Field',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Initially, no error text should be visible.
      expect(find.text('Field is required'), findsNothing);

      // Trigger the validation by calling formKey.currentState.validate().
      formKey.currentState?.validate();
      // Rebuild the widget to show the error text.
      await tester.pump();

      // Verify that the error message is now displayed.
      expect(find.text('Field is required'), findsOneWidget);
    });

    testWidgets('shows no validation error when validator returns null', (
      WidgetTester tester,
    ) async {
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController(text: 'Valid input');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: AuthFormField(
                controller: controller,
                labelText: 'Required Field',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Trigger validation.
      formKey.currentState?.validate();
      await tester.pump();

      // Verify that no error message is displayed.
      expect(find.text('Field is required'), findsNothing);
    });
  });
}
