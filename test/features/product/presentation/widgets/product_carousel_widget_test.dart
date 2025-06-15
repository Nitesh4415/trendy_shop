import 'dart:io';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/features/product/domain/entities/product.dart';
import 'package:shop_trendy/features/product/presentation/widgets/product_carousel.dart';

// Because CachedNetworkImage uses HttpClient, we mock these.
@GenerateMocks([
  GoRouter,
  HttpClient,
  HttpClientRequest,
  HttpClientResponse,
  HttpHeaders,
])
import 'product_carousel_widget_test.mocks.dart';

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
  final testProducts = [
    Product(
      id: 1,
      title: 'Product 1',
      price: 100.0,
      image: 'image1.png',
      description: '',
      category: '',
      rating: Rating(rate: 4, count: 10),
    ),
    Product(
      id: 2,
      title: 'Product 2',
      price: 200.0,
      image: 'image2.png',
      description: '',
      category: '',
      rating: Rating(rate: 5, count: 20),
    ),
  ];

  // Helper to pump the widget
  Future<void> pumpWidget(WidgetTester tester, List<Product> products) async {
    await tester.pumpWidget(
      MaterialApp(
        home: InheritedGoRouter(
          goRouter: mockGoRouter,
          child: Scaffold(body: ProductCarousel(products: products)),
        ),
      ),
    );
  }

  setUp(() {
    mockGoRouter = MockGoRouter();
  });

  group('ProductCarousel Widget Tests', () {
    testWidgets('renders SizedBox.shrink when product list is empty', (
      WidgetTester tester,
    ) async {
      await pumpWidget(tester, []);

      // Verify that the carousel and title are not rendered
      expect(find.byType(CarouselSlider), findsNothing);
      expect(find.text('Related Products'), findsNothing);
      // Verify that the empty container is rendered
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('renders title and carousel when product list is not empty', (
      WidgetTester tester,
    ) async {
      // Use HttpOverrides to mock network requests for images
      await HttpOverrides.runZoned(() async {
        await pumpWidget(tester, testProducts);

        // Verify the title and carousel are present
        expect(find.text('Related Products'), findsOneWidget);
        expect(find.byType(CarouselSlider), findsOneWidget);
      }, createHttpClient: (_) => createMockImageHttpClient());
    });

    testWidgets('displays product information correctly within the carousel', (
      WidgetTester tester,
    ) async {
      await HttpOverrides.runZoned(() async {
        await pumpWidget(tester, testProducts);

        // Verify that the details of the first product are visible
        // Note: CarouselSlider might render multiple instances, so we look for at least one.
        expect(find.text('Product 1'), findsWidgets);
        expect(find.text('\$100.00'), findsWidgets);
      }, createHttpClient: (_) => createMockImageHttpClient());
    });

    testWidgets('navigates to the correct product page on tap', (
      WidgetTester tester,
    ) async {
      await HttpOverrides.runZoned(() async {
        // Stub the push method before pumping the widget
        when(mockGoRouter.push(any)).thenAnswer((_) async {
          return null;
        });

        await pumpWidget(tester, testProducts);

        // --- FIX: Use a more direct finder and tap the text itself ---
        // The tap event will bubble up to the parent GestureDetector.
        final textFinder = find.text('Product 1');
        expect(textFinder, findsWidgets); // Ensure the widget is present

        // Act
        // Tap the first instance of the text widget found.
        await tester.tap(textFinder.first);
        await tester.pump();

        // Assert
        // Verify that GoRouter.push was called with the correct route
        verify(mockGoRouter.push('/products/1')).called(1);
      }, createHttpClient: (_) => createMockImageHttpClient());
    });
  });
}
