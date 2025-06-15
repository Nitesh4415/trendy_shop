import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart'; // Corrected import from .1 to .dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shop_trendy/core/constants/app_constants.dart';
import 'package:shop_trendy/firebase_options.dart';
import 'package:shop_trendy/core/di/injectable.dart';
import 'package:shop_trendy/core/routes/app_router.dart';
import 'package:shop_trendy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shop_trendy/features/product/presentation/cubit/product_cubit.dart';
import 'package:shop_trendy/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:shop_trendy/features/order/presentation/cubit/order_cubit/order_cubit.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; // For Stripe integration

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are initialized

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Stripe (for testing, use a dummy key or test publishable key)
  // For a real application,  fetch this securely, e.g., from a backend.
  Stripe.publishableKey = AppConstants
      .stripePublishableKey; // Replace with your test publishable key
  //  set a merchant identifier for Apple Pay
  // Stripe.merchantIdentifier = 'merchant.com.your_app_name'; // Example: 'merchant.com.my_shop_trendy'
  await Stripe.instance.applySettings();
  await configureDependencies(Environment.prod);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt.allReady(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        // If an error occurred during GetIt initialization
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(
                  'Error initializing dependencies: ${snapshot.error}',
                ),
              ),
            ),
          );
        }
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => getIt<AuthCubit>()..checkAuthStatus(),
            ),
            BlocProvider(create: (context) => getIt<ProductCubit>()),
            BlocProvider(create: (context) => getIt<CartCubit>()),
            BlocProvider(
              create: (context) => getIt<OrderCubit>(), // Initialize OrderCubit
            ),
          ],
          child: MaterialApp.router(
            title: 'Flutter E-commerce App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blueGrey,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            routerConfig: getIt<AppRouter>().router, // Use GoRouter
          ),
        );
      },
    );
  }
}
