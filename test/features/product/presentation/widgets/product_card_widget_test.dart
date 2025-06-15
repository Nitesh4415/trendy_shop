import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/features/product/domain/entities/product.dart';
import 'package:shop_trendy/features/product/presentation/widgets/product_card.dart';
import 'product_card_widget_test.mocks.dart';

// Generate a mock for GoRouter and HttpClient-related classes
@GenerateMocks([
  GoRouter,
  HttpClient,
  HttpClientRequest,
  HttpClientResponse,
  HttpHeaders,
])
// Transparent 1x1 pixel PNG image data to use as a mock response
final Uint8List kTransparentImage = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

// Helper function to create a mock HttpClient
MockHttpClient createMockImageHttpClient() {
  final client = MockHttpClient();
  final request = MockHttpClientRequest();
  final response = MockHttpClientResponse();
  final headers = MockHttpHeaders();

  when(client.getUrl(any)).thenAnswer((_) => Future.value(request));
  when(request.headers).thenReturn(headers);
  when(request.close()).thenAnswer((_) => Future.value(response));
  when(
    response.compressionState,
  ).thenReturn(HttpClientResponseCompressionState.notCompressed);
  when(response.contentLength).thenReturn(kTransparentImage.length);
  when(response.statusCode).thenReturn(HttpStatus.ok);
  when(
    response.listen(
      any,
      onDone: anyNamed('onDone'),
      onError: anyNamed('onError'),
      cancelOnError: anyNamed('cancelOnError'),
    ),
  ).thenAnswer((invocation) {
    final onData =
        invocation.positionalArguments[0] as void Function(List<int>);
    final onDone = invocation.namedArguments[#onDone] as void Function()?;
    return Stream.fromIterable([
      kTransparentImage,
    ]).listen(onData, onDone: onDone);
  });
  return client;
}

void main() {
  late MockGoRouter mockGoRouter;

  // Test product data
  final testProduct = Product(
    id: 101,
    title: 'Test Product Title',
    price: 199.99,
    description: 'A test description.',
    category: 'testing',
    image: 'https://example.com/image.png',
    rating: Rating(rate: 4.8, count: 123),
  );

  // Helper function to pump the widget with necessary providers
  Future<void> pumpProductCard(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: InheritedGoRouter(
          goRouter: mockGoRouter,
          child: Scaffold(body: ProductCard(product: testProduct)),
        ),
      ),
    );
  }

  setUp(() {
    mockGoRouter = MockGoRouter();
  });

  group('ProductCard Widget Tests', () {
    testWidgets('renders product information correctly', (
      WidgetTester tester,
    ) async {
      await HttpOverrides.runZoned(() async {
        await pumpProductCard(tester);

        // Verify that all the product details are displayed
        expect(find.text('Test Product Title'), findsOneWidget);
        expect(find.text('\$199.99'), findsOneWidget);
        expect(find.text('4.8'), findsOneWidget);
        expect(find.text(' (123)'), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
        expect(find.byType(Hero), findsOneWidget);
      }, createHttpClient: (_) => createMockImageHttpClient());
    });

    testWidgets('navigates to the correct product details page on tap', (
      WidgetTester tester,
    ) async {
      await HttpOverrides.runZoned(() async {
        await pumpProductCard(tester);

        // Act
        // Tap the InkWell area of the card
        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();

        // Assert
        // Verify that GoRouter was called with the correct route
        verify(mockGoRouter.go('/products/101')).called(1);
      }, createHttpClient: (_) => createMockImageHttpClient());
    });
  });
}
