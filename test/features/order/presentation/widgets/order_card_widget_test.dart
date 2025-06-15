import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/features/order/domain/entities/order.dart';
import 'package:shop_trendy/features/order/domain/entities/product_order.dart';
import 'package:shop_trendy/features/order/presentation/widget/order_card.dart';
import 'package:shop_trendy/features/product/domain/entities/product.dart';
import 'package:shop_trendy/features/product/presentation/cubit/product_cubit.dart';

// Generate mocks for the dependencies
@GenerateMocks([
  ProductCubit,
  GoRouter,
  HttpClient,
  HttpClientRequest,
  HttpClientResponse,
  HttpHeaders,
])
import 'order_card_widget_test.mocks.dart';

// Transparent 1x1 pixel PNG image data for mocking network images
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
  late MockProductCubit mockProductCubit;
  late MockGoRouter mockGoRouter;

  // Test data
  final product1 = Product(
    id: 101,
    title: 'Product One',
    price: 50.0,
    image: 'image1.png',
    description: '',
    category: '',
    rating: Rating(rate: 4, count: 10),
  );

  final testOrder = Orders(
    id: 123,
    userId: 1,
    date: DateTime(2023, 10, 27),
    products: [const ProductInOrder(productId: 101, quantity: 2)],
  );

  // Helper to pump the widget
  Future<void> pumpOrderCard(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: InheritedGoRouter(
          goRouter: mockGoRouter,
          child: BlocProvider<ProductCubit>.value(
            value: mockProductCubit,
            child: Scaffold(body: OrderCard(order: testOrder)),
          ),
        ),
      ),
    );
  }

  setUp(() {
    mockProductCubit = MockProductCubit();
    mockGoRouter = MockGoRouter();

    when(mockProductCubit.state).thenReturn(ProductInitial());
    when(mockProductCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  group('OrderCard Widget Tests', () {
    testWidgets('shows loading indicator initially and then data after fetch', (
      WidgetTester tester,
    ) async {
      await HttpOverrides.runZoned(() async {
        // Arrange
        // Use a Completer to control the async operation ---
        final completer = Completer<Product>();
        when(
          mockProductCubit.fetchProductDetailsInternal(any),
        ).thenAnswer((_) => completer.future);

        // Act: Initial pump
        await pumpOrderCard(tester);

        // Assert: Verify loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Act: Complete the future and rebuild the widget
        completer.complete(product1);
        await tester.pumpAndSettle();

        // Assert: Verify final state
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Product One'), findsOneWidget);
      }, createHttpClient: (_) => createMockImageHttpClient());
    });

    testWidgets('displays order and product details after loading', (
      WidgetTester tester,
    ) async {
      await HttpOverrides.runZoned(() async {
        // Arrange
        when(
          mockProductCubit.fetchProductDetailsInternal(101),
        ).thenAnswer((_) async => product1);

        // Act
        await pumpOrderCard(tester);
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Order ID: 123'), findsOneWidget);
        expect(find.text('Date: 2023-10-27'), findsOneWidget);
        expect(find.text('Product One'), findsOneWidget);
        expect(find.text('Qty: 2'), findsOneWidget);
        expect(find.text('\$100.00'), findsOneWidget); // 50.0 * 2
        expect(find.text('Total: \$100.00'), findsOneWidget);
      }, createHttpClient: (_) => createMockImageHttpClient());
    });

    testWidgets('navigates to product details page on tap', (
      WidgetTester tester,
    ) async {
      await HttpOverrides.runZoned(() async {
        // Arrange
        when(
          mockProductCubit.fetchProductDetailsInternal(101),
        ).thenAnswer((_) async => product1);
        when(mockGoRouter.go(any)).thenReturn(null);

        // Act
        await pumpOrderCard(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(InkWell, 'Product One'));
        await tester.pump();

        // Assert
        verify(mockGoRouter.go('/products/101')).called(1);
      }, createHttpClient: (_) => createMockImageHttpClient());
    });
  });
}
