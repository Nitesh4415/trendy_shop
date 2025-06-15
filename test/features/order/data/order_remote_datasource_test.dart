import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/core/constants/api_constants.dart';
import 'package:shop_trendy/core/error/exceptions.dart';
import 'package:shop_trendy/core/network/api_client.dart';
import 'package:shop_trendy/features/order/data/datasources/oder_datasource/order_remote_datasource_impl.dart';
import 'package:shop_trendy/features/order/data/models/order_model.dart';
import 'package:shop_trendy/features/order/data/models/product_order_model.dart';

// Generate a mock for ApiClient
@GenerateMocks([ApiClient])
import 'order_remote_datasource_test.mocks.dart';

void main() {
  late MockApiClient mockApiClient;
  late OrderRemoteDataSourceImpl dataSource;

  // Test data
  const testUserId = 1;
  final testDate = DateTime.now();

  // The OrderModel we expect our data source to construct
  final orderToPlace = OrderModel(
    userId: testUserId,
    date: testDate,
    products: [const ProductInOrderModel(productId: 1, quantity: 2)],
  );

  // The OrderModel we expect to get back after a successful post
  final placedOrderModel = OrderModel(
    id: 101,
    userId: testUserId,
    date: testDate,
    products: [const ProductInOrderModel(productId: 1, quantity: 2)],
  );

  final placedOrderJson = {
    'id': 101,
    'userId': testUserId,
    'date': testDate.toIso8601String(),
    'products': [
      {'productId': 1, 'quantity': 2},
    ],
  };

  // This is what the API would return for a successful GET.
  final orderHistoryJsonList = [
    {
      'id': 1,
      'userId': testUserId,
      'date': DateTime(2023, 1, 1).toIso8601String(),
      'products': [
        {'productId': 10, 'quantity': 1},
      ],
    },
    {
      'id': 2,
      'userId': testUserId,
      'date': DateTime(2023, 2, 2).toIso8601String(),
      'products': [
        {'productId': 20, 'quantity': 3},
      ],
    },
  ];

  // This is the list of OrderModel objects we expect after parsing the JSON list.
  final expectedOrderHistoryList = [
    OrderModel(
      id: 1,
      userId: testUserId,
      date: DateTime(2023, 1, 1),
      products: [const ProductInOrderModel(productId: 10, quantity: 1)],
    ),
    OrderModel(
      id: 2,
      userId: testUserId,
      date: DateTime(2023, 2, 2),
      products: [const ProductInOrderModel(productId: 20, quantity: 3)],
    ),
  ];

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = OrderRemoteDataSourceImpl(mockApiClient);
  });

  group('OrderRemoteDataSourceImpl', () {
    group('placeOrder', () {
      test(
        'should return OrderModel when the API call is successful',
        () async {
          // Arrange
          when(
            mockApiClient.post(ApiConstants.orders, any),
          ).thenAnswer((_) async => placedOrderJson);

          // Act
          final result = await dataSource.placeOrder(orderToPlace);

          // Assert
          expect(result, equals(placedOrderModel));
          verify(
            mockApiClient.post(ApiConstants.orders, orderToPlace.toJson()),
          ).called(1);
        },
      );

      test('should throw a ServerException when the API call fails', () async {
        // Arrange
        when(mockApiClient.post(any, any)).thenThrow(ServerException());

        // Act
        final call = dataSource.placeOrder;

        // Assert
        expect(() => call(orderToPlace), throwsA(isA<ServerException>()));
      });
    });

    group('getOrderHistory', () {
      test(
        'should return a list of OrderModel when the API call is successful',
        () async {
          // Arrange
          when(
            mockApiClient.get('${ApiConstants.orders}/user/$testUserId'),
          ).thenAnswer((_) async => orderHistoryJsonList);

          // Act
          final result = await dataSource.getOrderHistory(testUserId);

          // Assert
          expect(result, equals(expectedOrderHistoryList));
          verify(
            mockApiClient.get('${ApiConstants.orders}/user/$testUserId'),
          ).called(1);
        },
      );

      test(
        'should return an empty list when the API call is successful but returns no data',
        () async {
          // Arrange
          when(mockApiClient.get(any)).thenAnswer((_) async => []);

          // Act
          final result = await dataSource.getOrderHistory(testUserId);

          // Assert
          expect(result, isEmpty);
        },
      );

      test('should throw a ServerException when the API call fails', () async {
        // Arrange
        when(mockApiClient.get(any)).thenThrow(ServerException());

        // Act
        final call = dataSource.getOrderHistory;

        // Assert
        expect(() => call(testUserId), throwsA(isA<ServerException>()));
      });
    });
  });
}
