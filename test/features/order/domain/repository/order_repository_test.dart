import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/core/error/exceptions.dart';
import 'package:shop_trendy/features/order/data/datasources/oder_datasource/order_remote_datasource.dart';
import 'package:shop_trendy/features/order/data/models/order_model.dart';
import 'package:shop_trendy/features/order/data/models/product_order_model.dart';
import 'package:shop_trendy/features/order/data/repositories/order_repository_impl.dart';
import 'package:shop_trendy/features/order/domain/entities/order.dart';
import 'package:shop_trendy/features/order/domain/entities/product_order.dart';
import 'package:shop_trendy/features/order/domain/repositories/order_repository.dart';

// Generate a mock for OrderRemoteDataSource
@GenerateMocks([OrderRemoteDataSource])
import 'order_repository_test.mocks.dart';

void main() {
  late MockOrderRemoteDataSource mockRemoteDataSource;
  late OrderRepository repository;

  // Test data
  const tUserId = 1;
  final tOrderEntity = Orders(
    userId: tUserId,
    date: DateTime.now(),
    products: [const ProductInOrder(productId: 1, quantity: 2)],
  );

  final tOrderModel = OrderModel(
    userId: tUserId,
    date: tOrderEntity.date,
    products: [const ProductInOrderModel(productId: 1, quantity: 2)],
  );

  final tPlacedOrderModel = tOrderModel.copyWith(id: 101);
  final tPlacedOrderEntity = tOrderEntity.copyWith(id: 101);

  final tOrderModelList = [
    OrderModel(
      id: 1,
      userId: tUserId,
      date: DateTime(2023, 1, 1),
      products: [const ProductInOrderModel(productId: 10, quantity: 1)],
    ),
    OrderModel(
      id: 2,
      userId: tUserId,
      date: DateTime(2023, 2, 2),
      products: [const ProductInOrderModel(productId: 20, quantity: 3)],
    ),
  ];

  final tOrderEntityList = [
    Orders(
      id: 1,
      userId: tUserId,
      date: DateTime(2023, 1, 1),
      products: [const ProductInOrder(productId: 10, quantity: 1)],
    ),
    Orders(
      id: 2,
      userId: tUserId,
      date: DateTime(2023, 2, 2),
      products: [const ProductInOrder(productId: 20, quantity: 3)],
    ),
  ];

  setUp(() {
    mockRemoteDataSource = MockOrderRemoteDataSource();
    repository = OrderRepositoryImpl(mockRemoteDataSource);
  });

  group('OrderRepositoryImpl', () {
    group('getOrderHistory', () {
      test(
        'should return a list of Orders entities when the call to remote data source is successful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.getOrderHistory(any),
          ).thenAnswer((_) async => tOrderModelList);

          // Act
          final result = await repository.getOrderHistory(tUserId);

          // Assert
          expect(result, equals(tOrderEntityList));
          verify(mockRemoteDataSource.getOrderHistory(tUserId));
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should rethrow a ServerException when the call to remote data source is unsuccessful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.getOrderHistory(any),
          ).thenThrow(ServerException());

          // Act
          final call = repository.getOrderHistory;

          // Assert
          expect(() => call(tUserId), throwsA(isA<ServerException>()));
        },
      );
    });

    group('placeOrder', () {
      test(
        'should return an Orders entity when the call to remote data source is successful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.placeOrder(any),
          ).thenAnswer((_) async => tPlacedOrderModel);

          // Act
          final result = await repository.placeOrder(tOrderEntity);

          // Assert
          expect(result, equals(tPlacedOrderEntity));
          // Verify that the correct model was passed to the data source
          verify(mockRemoteDataSource.placeOrder(tOrderModel));
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should rethrow a ServerException when the call to remote data source is unsuccessful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.placeOrder(any),
          ).thenThrow(ServerException());

          // Act
          final call = repository.placeOrder;

          // Assert
          expect(() => call(tOrderEntity), throwsA(isA<ServerException>()));
        },
      );
    });
  });
}
