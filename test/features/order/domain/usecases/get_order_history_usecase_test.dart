import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/core/error/exceptions.dart';
import 'package:shop_trendy/features/order/domain/entities/order.dart';
import 'package:shop_trendy/features/order/domain/entities/product_order.dart';
import 'package:shop_trendy/features/order/domain/repositories/order_repository.dart';
import 'package:shop_trendy/features/order/domain/usecases/get_order_history_usecase.dart';

// Generate a mock for OrderRepository
@GenerateMocks([OrderRepository])
import 'get_order_history_usecase_test.mocks.dart';

void main() {
  late MockOrderRepository mockOrderRepository;
  late GetOrderHistoryUseCase usecase;

  // Test data
  const tUserId = 1;
  final tOrderList = [
    Orders(
      id: 1,
      userId: tUserId,
      date: DateTime(2023, 10, 26),
      products: [const ProductInOrder(productId: 101, quantity: 1)],
    ),
    Orders(
      id: 2,
      userId: tUserId,
      date: DateTime(2023, 10, 27),
      products: [const ProductInOrder(productId: 102, quantity: 2)],
    ),
  ];

  setUp(() {
    mockOrderRepository = MockOrderRepository();
    usecase = GetOrderHistoryUseCase(mockOrderRepository);
  });

  group('GetOrderHistoryUseCase', () {
    test('should get a list of orders from the repository', () async {
      // Arrange
      // Stub the repository method to return a successful result.
      when(
        mockOrderRepository.getOrderHistory(any),
      ).thenAnswer((_) async => tOrderList);

      // Act
      // Execute the use case with the test user ID.
      final result = await usecase(tUserId);

      // Assert
      // Expect that the result from the use case matches the one from the repository.
      expect(result, tOrderList);
      // Verify that the repository method was called with the correct user ID.
      verify(mockOrderRepository.getOrderHistory(tUserId));
      // Ensure no other methods were called on the repository.
      verifyNoMoreInteractions(mockOrderRepository);
    });

    test(
      'should re-throw the exception from the repository when getting order history fails',
      () async {
        // Arrange
        // Stub the repository method to throw an exception.
        final serverException = ServerException();
        when(
          mockOrderRepository.getOrderHistory(any),
        ).thenThrow(serverException);

        // Act
        // Define the call to the use case.
        final call = usecase;

        // Assert
        // Expect that calling the use case throws the same exception.
        expect(() => call(tUserId), throwsA(isA<ServerException>()));
      },
    );
  });
}
