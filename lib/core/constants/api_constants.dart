class ApiConstants {
  static const String fakeStoreApiUrl = 'https://fakestoreapi.com';
  static const String backendBaseUrl = 'https://stripe-payment-server-9ctk.onrender.com';
  // Endpoint for fetching all products.
  static const String products = '/products';

  // Placeholder for product details endpoint.
  static String productDetails(int id) => '/products/$id';

  static const String orders = '/carts';

  // Endpoint for users
  static const String users = '/users';
}
