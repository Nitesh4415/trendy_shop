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
import 'package:flutter_stripe/flutter_stripe.dart';// For Stripe integration

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are initialized

  // Initialize Firebase
  // IMPORTANT: You need to set up your Firebase project and generate firebase_options.dart
  // Run `flutterfire configure` in your project root after setting up Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Stripe (for testing, use a dummy key or test publishable key)
  // For a real application,  fetch this securely, e.g., from a backend.
  Stripe.publishableKey =
      AppConstants.stripePublishableKey; // Replace with your test publishable key
  //  set a merchant identifier for Apple Pay
  // Stripe.merchantIdentifier = 'merchant.com.your_app_name'; // Example: 'merchant.com.my_shop_trendy'
  await Stripe.instance.applySettings();

  // Configure dependency injection using injectable
  await configureDependencies(Environment.prod);

  // Now, runApp will only be called after all dependencies are configured.
  // We'll wrap MyApp in a FutureBuilder to ensure GetIt is fully ready before building.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // The future will complete when all GetIt dependencies are ready
      future: getIt.allReady(),
      builder: (context, snapshot) {
        // While waiting for GetIt to be ready, show a loading indicator
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

        // Once GetIt is ready, build the main application
        return MultiBlocProvider(
          providers: [
            // Provide AuthCubit throughout the app
            BlocProvider(
              create: (context) => getIt<AuthCubit>()..checkAuthStatus(),
            ),
            // Provide ProductCubit throughout the app
            BlocProvider(create: (context) => getIt<ProductCubit>()),
            // Provide CartCubit throughout the app
            BlocProvider(
              create: (context) =>
                  getIt<CartCubit>()
                    ..loadCartItems(), // Load cart items on app start
            ),
            // Provide OrderCubit throughout the app
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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