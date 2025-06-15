import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import '../network/payment_api_client.dart';
import '../routes/app_router.dart';

@module
abstract class RegisterModule {
  @preResolve
  Future<AppRouter> get appRouter async => AppRouter();

  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn();

  @lazySingleton
  Dio get dio => Dio();

  @lazySingleton
  PaymentApiClient paymentApiClient(
    @Named('paymentBackendUrl') String backendUrl,
    Dio dio,
  ) {
    return PaymentApiClient(baseUrl: backendUrl, dio: dio);
  }
}
