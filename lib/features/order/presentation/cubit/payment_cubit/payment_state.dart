part of 'payment_cubit.dart';

@freezed
class PaymentState with _$PaymentState {
  const factory PaymentState.initial() = _Initial;
  const factory PaymentState.loading() = _Loading;
  const factory PaymentState.success(String message) = _Success;
  const factory PaymentState.error(PaymentFailure failure) = _Error;
}
