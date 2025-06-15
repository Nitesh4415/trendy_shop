import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_trendy/features/product/presentation/widgets/custom_pagination.dart';

void main() {
  group('CustomPaginationControls Widget Tests', () {
    testWidgets('renders the "Load More" button correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaginationControls(
              onLoadMore: () async {}, // Provide a dummy function
            ),
          ),
        ),
      );

      // Assert
      // Verify that the ElevatedButton with the correct text is found.
      expect(find.widgetWithText(ElevatedButton, 'Load More'), findsOneWidget);
    });

    testWidgets('calls onLoadMore callback when the button is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool wasCalled = false;
      // Define a callback function that sets our flag to true when called.
      Future<void> mockOnLoadMore() async {
        wasCalled = true;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaginationControls(onLoadMore: mockOnLoadMore),
          ),
        ),
      );

      // Act
      // Tap the "Load More" button.
      await tester.tap(find.byType(ElevatedButton));
      // Wait for any animations to complete.
      await tester.pumpAndSettle();

      // Assert
      // Verify that our callback function was executed.
      expect(wasCalled, isTrue);
    });

    testWidgets('button is tappable', (WidgetTester tester) async {
      // Arrange
      int callCount = 0;
      Future<void> mockOnLoadMore() async {
        callCount++;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaginationControls(onLoadMore: mockOnLoadMore),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(callCount, 2);
    });
  });
}
