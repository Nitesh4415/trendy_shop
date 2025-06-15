import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/core/error/exceptions.dart';
import 'package:shop_trendy/features/payment/domain/repositories/stripe_payment_repository.dart';
import 'package:shop_trendy/features/payment/domain/usecases/create_payment_intent_usecase.dart';

// Generate a mock for StripePaymentRepository
@GenerateMocks([StripePaymentRepository])
import 'create_payment_intent_usecase_test.mocks.dart';

void main() {
  late MockStripePaymentRepository mockStripePaymentRepository;
  late CreatePaymentIntentUseCase usecase;

  setUp(() {
    mockStripePaymentRepository = MockStripePaymentRepository();
    usecase = CreatePaymentIntentUseCase(mockStripePaymentRepository);
  });

  group('CreatePaymentIntentUseCase', () {
    const testAmount = 99.99;
    const testCurrency = 'usd';
    const testClientSecret = 'pi_12345_secret_ABCDE';

    test('should get client secret from the repository', () async {
      // Arrange
      // Stub the repository method to return a successful result.
      when(
        mockStripePaymentRepository.createPaymentIntent(
          testAmount,
          testCurrency,
        ),
      ).thenAnswer((_) async => testClientSecret);

      // Act
      // Execute the use case.
      final result = await usecase(testAmount, testCurrency);

      // Assert
      // Expect that the result from the use case matches the one from the repository.
      expect(result, testClientSecret);
      // Verify that the repository method was called with the correct parameters.
      verify(
        mockStripePaymentRepository.createPaymentIntent(
          testAmount,
          testCurrency,
        ),
      );
      // Ensure no other methods were called on the repository.
      verifyNoMoreInteractions(mockStripePaymentRepository);
    });

    test('should re-throw the exception from the repository', () async {
      // Arrange
      // Stub the repository method to throw an exception.
      final serverException = PaymentException('Payment Gateway Error');
      when(
        mockStripePaymentRepository.createPaymentIntent(any, any),
      ).thenThrow(serverException);

      // Act
      // Define the call to the use case.
      final call = usecase;

      // Assert
      // Expect that the call to the use case throws the same exception.
      expect(
        () => call(testAmount, testCurrency),
        throwsA(isA<PaymentException>()),
      );
    });
  });
}
