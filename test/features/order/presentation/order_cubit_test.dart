import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/features/order/domain/entities/order.dart';
import 'package:shop_trendy/features/order/domain/entities/product_order.dart';
import 'package:shop_trendy/features/order/domain/usecases/get_order_history_usecase.dart';
import 'package:shop_trendy/features/order/domain/usecases/place_order_usecase.dart';
import 'package:shop_trendy/features/order/presentation/cubit/order_cubit/order_cubit.dart';

@GenerateMocks([GetOrderHistoryUseCase, PlaceOrderUseCase])
import 'order_cubit_test.mocks.dart';

void main() {
  late MockGetOrderHistoryUseCase mockGetOrderHistoryUseCase;
  late MockPlaceOrderUseCase mockPlaceOrderUseCase;
  late OrderCubit orderCubit;

  // Test data
  final order1 = Orders(
    id: 1,
    userId: 1,
    date: DateTime(2023, 1, 1),
    products: [const ProductInOrder(productId: 101, quantity: 1)],
  );
  final order2 = Orders(
    id: 2,
    userId: 1,
    date: DateTime(2023, 2, 2),
    products: [const ProductInOrder(productId: 102, quantity: 2)],
  );
  final newOrderToPlace = Orders(
    userId: 1,
    date: DateTime.now(),
    products: [const ProductInOrder(productId: 103, quantity: 3)],
  );
  // Simulate the order after it gets an ID from the backend
  final placedOrder = newOrderToPlace.copyWith(id: 3);

  setUp(() {
    mockGetOrderHistoryUseCase = MockGetOrderHistoryUseCase();
    mockPlaceOrderUseCase = MockPlaceOrderUseCase();
    orderCubit = OrderCubit(mockGetOrderHistoryUseCase, mockPlaceOrderUseCase);
  });

  group('OrderCubit', () {
    test('initial state is OrderInitial', () {
      expect(orderCubit.state, isA<OrderInitial>());
    });

    group('fetchOrderHistory', () {
      blocTest<OrderCubit, OrderState>(
        'emits [OrderLoading, OrderAllLoaded] and correctly separates current from past orders',
        setUp: () {
          // The use case should return orders sorted newest to oldest from the repository
          when(
            mockGetOrderHistoryUseCase.call(any),
          ).thenAnswer((_) async => [order2, order1]);
        },
        build: () => orderCubit,
        act: (cubit) => cubit.fetchOrderHistory(1),
        expect: () => [
          isA<OrderLoading>(),
          // The newest order (order2) should be current, the rest should be in pastOrders
          OrderAllLoaded(currentOrder: order2, pastOrders: [order1]),
        ],
        verify: (_) {
          verify(mockGetOrderHistoryUseCase.call(1)).called(1);
        },
      );

      blocTest<OrderCubit, OrderState>(
        'emits OrderAllLoaded with null current order and empty past orders if history is empty',
        setUp: () {
          when(
            mockGetOrderHistoryUseCase.call(any),
          ).thenAnswer((_) async => []);
        },
        build: () => orderCubit,
        act: (cubit) => cubit.fetchOrderHistory(1),
        expect: () => [
          isA<OrderLoading>(),
          const OrderAllLoaded(currentOrder: null, pastOrders: []),
        ],
      );

      blocTest<OrderCubit, OrderState>(
        'emits OrderError when use case throws an exception',
        setUp: () {
          when(
            mockGetOrderHistoryUseCase.call(any),
          ).thenThrow(Exception('Failed to fetch'));
        },
        build: () => orderCubit,
        act: (cubit) => cubit.fetchOrderHistory(1),
        expect: () => [
          isA<OrderLoading>(),
          isA<OrderError>().having(
            (e) => e.message,
            'message',
            'Exception: Failed to fetch',
          ),
        ],
      );
    });

    group('createOrder', () {
      blocTest<OrderCubit, OrderState>(
        'emits OrderAllLoaded with new order as current and moves old current to past',
        setUp: () {
          when(
            mockPlaceOrderUseCase.call(any),
          ).thenAnswer((_) async => placedOrder);
        },
        build: () => orderCubit,
        // Seed the state with a pre-existing order history
        seed: () => OrderAllLoaded(currentOrder: order2, pastOrders: [order1]),
        act: (cubit) => cubit.createOrder(newOrderToPlace),
        expect: () => [
          // The new order (placedOrder) is now current.
          // The old current order (order2) is now the first in the past list.
          OrderAllLoaded(
            currentOrder: placedOrder,
            pastOrders: [order2, order1],
          ),
        ],
        verify: (_) {
          verify(mockPlaceOrderUseCase.call(newOrderToPlace)).called(1);
        },
      );

      blocTest<OrderCubit, OrderState>(
        'emits OrderAllLoaded with new order as current when there was no previous order',
        setUp: () {
          when(
            mockPlaceOrderUseCase.call(any),
          ).thenAnswer((_) async => placedOrder);
        },
        build: () => orderCubit,
        // Seed the state with no orders
        seed: () => const OrderAllLoaded(currentOrder: null, pastOrders: []),
        act: (cubit) => cubit.createOrder(newOrderToPlace),
        expect: () => [
          OrderAllLoaded(currentOrder: placedOrder, pastOrders: []),
        ],
      );
    });

    group('getOrderById', () {
      test('returns the current order when ID matches', () {
        orderCubit.emit(
          OrderAllLoaded(currentOrder: order2, pastOrders: [order1]),
        );
        final result = orderCubit.getOrderById(2);
        expect(result, order2);
      });

      test('returns a past order when ID matches', () {
        orderCubit.emit(
          OrderAllLoaded(currentOrder: order2, pastOrders: [order1]),
        );
        final result = orderCubit.getOrderById(1);
        expect(result, order1);
      });

      test('returns null if no order ID matches', () {
        orderCubit.emit(
          OrderAllLoaded(currentOrder: order2, pastOrders: [order1]),
        );
        final result = orderCubit.getOrderById(99);
        expect(result, isNull);
      });
    });
  });
}
