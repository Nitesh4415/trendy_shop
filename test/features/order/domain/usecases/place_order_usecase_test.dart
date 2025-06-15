import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/core/error/exceptions.dart';
import 'package:shop_trendy/features/order/domain/entities/order.dart';
import 'package:shop_trendy/features/order/domain/entities/product_order.dart';
import 'package:shop_trendy/features/order/domain/repositories/order_repository.dart';
import 'package:shop_trendy/features/order/domain/usecases/place_order_usecase.dart';

// Generate a mock for OrderRepository
@GenerateMocks([OrderRepository])
import 'place_order_usecase_test.mocks.dart';

void main() {
  late MockOrderRepository mockOrderRepository;
  late PlaceOrderUseCase usecase;

  // Test data: an order object to be placed
  final tOrderToPlace = Orders(
    userId: 1,
    date: DateTime.now(),
    products: [const ProductInOrder(productId: 101, quantity: 2)],
  );

  // Test data: the order object after it has been placed (with an ID)
  final tPlacedOrder = tOrderToPlace.copyWith(id: 123);

  setUp(() {
    mockOrderRepository = MockOrderRepository();
    usecase = PlaceOrderUseCase(mockOrderRepository);
  });

  group('PlaceOrderUseCase', () {
    test(
      'should return an Orders entity from the repository when an order is placed successfully',
      () async {
        // Arrange
        // Stub the repository method to return the successfully placed order.
        when(
          mockOrderRepository.placeOrder(any),
        ).thenAnswer((_) async => tPlacedOrder);

        // Act
        // Execute the use case with the order data.
        final result = await usecase(tOrderToPlace);

        // Assert
        // Expect that the result from the use case matches the one from the repository.
        expect(result, tPlacedOrder);
        // Verify that the repository method was called with the correct order data.
        verify(mockOrderRepository.placeOrder(tOrderToPlace));
        // Ensure no other methods were called on the repository.
        verifyNoMoreInteractions(mockOrderRepository);
      },
    );

    test(
      'should re-throw the exception from the repository when placing an order fails',
      () async {
        // Arrange
        // Stub the repository method to throw an exception.
        final serverException = ServerException();
        when(mockOrderRepository.placeOrder(any)).thenThrow(serverException);

        // Act
        // Define the call to the use case.
        final call = usecase;

        // Assert
        // Expect that calling the use case throws the same exception.
        expect(() => call(tOrderToPlace), throwsA(isA<ServerException>()));
      },
    );
  });
}
