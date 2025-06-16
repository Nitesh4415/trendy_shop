# Shop Trendy - Flutter E-commerce App
   A modern, feature-rich e-commerce mobile application built with Flutter. "Shop Trendy" provides a complete shopping experience, from browsing products to secure checkout, all powered by a robust and scalable architecture.

## 1. Project Overview
   Shop Trendy is a sample e-commerce application designed to demonstrate a clean, feature-first architecture using modern Flutter development practices. It includes user authentication, a dynamic product catalog, a persistent shopping cart, and a complete checkout flow with payment integration.

### Core Features
- User Authentication: Secure sign-up and login with Email/Password and Google Sign-In via Firebase.

- Product Catalog: Paginated product list with infinite scrolling, product detail view, and related items carousel.

- Shopping Cart: Locally persistent cart per user, allowing users to add, remove, and update item quantities.

- Order Management: Users can place orders and view their current order and order history.

- Payment Integration: Secure checkout process powered by Stripe.

### Tech Stack
- Framework: Flutter & Dart

- State Management: flutter_bloc / cubit

- Navigation: go_router

- Dependency Injection: injectable and get_it

- Networking: dio

- Authentication: firebase_auth

- Local Storage: sqflite

- Payment Gateway: flutter_stripe

## 2. Architecture & Design Principles
   This project is built upon the principles of Clean Architecture to create a separation of concerns, making the codebase decoupled, testable, and easy to maintain. The architecture is divided into three primary layers for each feature: Presentation, Domain, and Data.

### Feature-First Structure
   The project follows a feature-first directory structure. All the code related to a specific feature (like auth, product, or cart) is grouped together, with each feature containing its own presentation, domain, and data layers.
```bash
lib/
└── features/
└── product/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
├── cubit/
├── pages/
└── widgets/
```

### The Three Layers

### Domain Layer
- **What it is:** This is the core of the application. It contains the business logic and rules. It is completely independent of any other layer.

- Components:

-  Entities: Plain Dart objects representing the core business models (e.g., Product, User).

-  Repositories (Abstract): Interfaces that define the contract for what the data layer must implement (e.g., ProductRepository with a method like Future<List<Product>> getProducts()).

- Use Cases (Interactors): Classes that encapsulate a single, specific business rule. They orchestrate the flow of data by using the abstract repositories.

### Data Layer
- What it is: This layer is responsible for all data retrieval and storage. It implements the repository interfaces defined in the domain layer.

- Components:

-  Models: Data Transfer Objects (DTOs) that extend domain entities. They include methods for serializing and deserializing data (e.g., fromJson, toJson).

-  Data Sources (Abstract & Concrete): Interfaces and their implementations for fetching data from specific sources, like a REST API (RemoteDataSource) or a local database (LocalDataSource).

-  Repositories (Concrete): Implementations of the repository interfaces from the domain layer. They coordinate data from one or more data sources.

### Presentation Layer
- What it is: This layer contains everything related to the UI. It is the only layer that the user directly interacts with.

- Components:

-  UI (Pages/Widgets): The Flutter widgets that make up the user interface.

-  State Management (Cubits/Blocs): These components manage the state of the UI. They interact with the domain layer (via use cases) to get data and handle user actions, then emit new states to update the UI.

### Adherence to SOLID Principles
The architecture is designed to follow the SOLID principles:

- Single Responsibility Principle (SRP): Each class has one job. A use case handles one business rule, a repository handles data operations for one entity, and a cubit manages the state for one screen.

- Open/Closed Principle: The use of abstractions (repository interfaces) allows us to add new data sources (e.g., a GraphQL API) without modifying the existing domain or presentation layers.

- Liskov Substitution Principle: Subtypes (repository implementations) are substitutable for their base types (repository interfaces).

- Interface Segregation Principle: By creating specific repositories for each feature (e.g., AuthRepository, ProductRepository), we ensure that clients (use cases) only depend on the methods they use.

- Dependency Inversion Principle: High-level modules (the domain layer) do not depend on low-level modules (the data layer). Both depend on abstractions (the repository interfaces). This is facilitated by our use of get_it and injectable for dependency injection.

## 3. Environment & Version Setup
   This project has been tested with the following environment configuration. It is recommended to use versions as close as possible to these to ensure compatibility.

- Flutter: 3.32.2

- Dart: 3.8.1

- Xcode: 16.1

- CocoaPods: 1.16.2

- Android SDK: 35.0.0

- Android Studio: 2024.3

### Flutter Setup
First, ensure your Flutter environment is correctly configured.

      flutter doctor

Address any issues reported by flutter doctor before proceeding.

### iOS Setup (macOS only)
1. ## Install Xcode:

   Ensure you have Xcode version 16.1 or later from the Mac App Store.

2. ## Install CocoaPods:
   If not already installed, run:
    
       gem install cocoapods

3. ## Install Pods:
   Navigate to the ios directory of the project and run:
   
        pod install

4. ## Open Xcode:
    Open the Runner.xcworkspace file (not Runner.xcodeproj) in the ios directory.

5. ## Configure Signing:
   In Xcode, select the "Runner" target, go to the "Signing & Capabilities" tab, and select your development team.

### Android Setup
1. ### Install Android Studio:
   Ensure you have Android Studio version 2024.3 or later.

2. ### Android SDK:
   Use the SDK Manager in Android Studio to install Android SDK Platform 35.

3. ### Emulator/Device:
   Set up an Android Emulator (API 34+) or connect a physical Android device with USB debugging enabled.

## 4. Backend & Service Configuration
   This project requires external services for authentication and payments.

Firebase Setup
The app uses Firebase for user authentication.

1. ## Create Firebase Project:
   Go to the Firebase Console and create a new project.

2. ## Connect Flutter App: 
   Follow the official guide to add Firebase to your Flutter app by running the flutterfire configure command from your project's root directory. This will automatically generate the firebase_options.dart file.

        flutterfire configure

3. ### Download Configuration Files (Manual Fallback):

   For Android, add an Android app in your Firebase project settings. Follow the setup steps and download the google-services.json file. Place it in the android/app/ directory.

   For iOS, add an iOS app in your Firebase project settings. Follow the setup steps and download the GoogleService-Info.plist file. Open ios/Runner.xcworkspace in Xcode and drag this file into the Runner/Runner folder.

4. ### Enable Authentication Methods:
   In the Firebase Console, go to Authentication > Sign-in method and enable the Email/Password and Google providers.

## Stripe Payment Integration
The app uses Stripe for payment processing.

1. ### Create a Stripe Account:
   Sign up for a free account at stripe.com.

2. ### Get API Keys: 
   In your Stripe Dashboard, go to Developers > API keys. You will need your Publishable key.

      Note: For testing, make sure you are using your "Test data" keys.

3. ### Update App Constants: Open lib/core/constants/app_constants.dart and replace the placeholder with your Test Publishable Key:

   static const String stripePublishableKey = 'pk_test_YOUR_PUBLISHABLE_KEY';

4. ### Backend for PaymentIntents:
   Stripe requires a backend service to securely create a PaymentIntent and return a clientSecret to the app. The app's PaymentApiClient expects this backend to be running. You must set up your own simple server (e.g., using Node.js, Python, or a serverless function) that uses your Stripe Secret Key to create payment intents.

5. ### Update Backend URL:
   Update the paymentBackendUrl in lib/core/di/injectable.dart to point to your payment backend.

## 5. Running the Project

1. ### Clone the Repository:

        git clone https://github.com/Nitesh4415/trendy_shop.git
        cd shop_trendy

2. ### Install Dependencies:

         flutter pub get

3. ### Run Build Runner:
   This generates the necessary files for dependency injection and data models.

         flutter pub run build_runner build --delete-conflicting-outputs

4. ### Run the App:
   Make sure you have an emulator running or a device connected.

         flutter run

## 6. Testing
   To run all the unit and widget tests in the project, use the following command:

        flutter test

   This will execute all files ending in _test.dart and provide a summary of the results.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
