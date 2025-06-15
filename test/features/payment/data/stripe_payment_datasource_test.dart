import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/core/error/exceptions.dart';
import 'package:shop_trendy/core/network/payment_api_client.dart';
import 'package:shop_trendy/features/payment/data/datasources/stripe_payment_datasource_impl.dart';

// Generate a mock for PaymentApiClient
@GenerateMocks([PaymentApiClient])
import 'stripe_payment_datasource_test.mocks.dart';

void main() {
  late MockPaymentApiClient mockPaymentApiClient;
  late StripePaymentRemoteDataSourceImpl dataSource;

  setUp(() {
    mockPaymentApiClient = MockPaymentApiClient();
    dataSource = StripePaymentRemoteDataSourceImpl(mockPaymentApiClient);
  });

  group('StripePaymentRemoteDataSourceImpl', () {
    group('createPaymentIntent', () {
      const testAmount = 100.0;
      const testCurrency = 'usd';
      const testClientSecret = 'pi_12345_secret_67890';

      test(
        'should return a client secret string when the API call is successful',
        () async {
          // Arrange
          when(
            mockPaymentApiClient.createPaymentIntent(testAmount, testCurrency),
          ).thenAnswer((_) async => testClientSecret);

          // Act
          final result = await dataSource.createPaymentIntent(
            testAmount,
            testCurrency,
          );

          // Assert
          expect(result, equals(testClientSecret));
          verify(
            mockPaymentApiClient.createPaymentIntent(testAmount, testCurrency),
          ).called(1);
        },
      );

      test(
        'should re-throw a ServerException when the API call fails',
        () async {
          // Arrange
          when(
            mockPaymentApiClient.createPaymentIntent(any, any),
          ).thenThrow(PaymentException('Payment failed'));

          // Act
          final call = dataSource.createPaymentIntent;

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
