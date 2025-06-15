import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/core/error/exceptions.dart';
import 'package:shop_trendy/features/payment/data/datasources/stripe_payment_datasource.dart';
import 'package:shop_trendy/features/payment/data/repositories/stripe_payment_repository_impl.dart';
import 'package:shop_trendy/features/payment/domain/repositories/stripe_payment_repository.dart';

// Generate a mock for StripePaymentRemoteDataSource
@GenerateMocks([StripePaymentRemoteDataSource])
import 'stripe_payment_repository_test.mocks.dart';

void main() {
  late MockStripePaymentRemoteDataSource mockRemoteDataSource;
  late StripePaymentRepository repository;

  setUp(() {
    mockRemoteDataSource = MockStripePaymentRemoteDataSource();
    repository = StripePaymentRepositoryImpl(mockRemoteDataSource);
  });

  group('PaymentRepositoryImpl', () {
    group('createPaymentIntent', () {
      const testAmount = 150.50;
      const testCurrency = 'eur';
      const testClientSecret = 'pi_abcdef_secret_ghijkl';

      test(
        'should return client secret string when the call to remote data source is successful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.createPaymentIntent(testAmount, testCurrency),
          ).thenAnswer((_) async => testClientSecret);

          // Act
          final result = await repository.createPaymentIntent(
            testAmount,
            testCurrency,
          );

          // Assert
          expect(result, equals(testClientSecret));
          verify(
            mockRemoteDataSource.createPaymentIntent(testAmount, testCurrency),
          );
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should re-throw the exception when the call to remote data source is unsuccessful',
        () async {
          // Arrange
          final serverException = PaymentException('API Error');
          when(
            mockRemoteDataSource.createPaymentIntent(any, any),
          ).thenThrow(serverException);

          // Act
          final call = repository.createPaymentIntent;

          // Assert
          expect(
            () => call(testAmount, testCurrency),
            throwsA(isA<PaymentException>()),
          );
        },
      );
    });
  });
}
