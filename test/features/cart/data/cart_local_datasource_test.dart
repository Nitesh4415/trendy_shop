import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/core/database/database_helper.dart';
import 'package:shop_trendy/features/cart/data/datasources/cart_local_datasource_impl.dart';
import 'package:shop_trendy/features/cart/domain/entities/cart_item.dart';
import 'package:shop_trendy/features/product/domain/entities/product.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Generate a mock for DatabaseHelper
@GenerateMocks([DatabaseHelper])
import 'cart_local_datasource_test.mocks.dart';

void main() {
  // Use sqflite_common_ffi for in-memory database testing
  sqfliteFfiInit();
  final databaseFactory = databaseFactoryFfi;

  late MockDatabaseHelper mockDatabaseHelper;
  late CartLocalDataSourceImpl dataSource;
  late Database database;

  // Test data for two different users
  const user1Email = 'user1@example.com';
  const user2Email = 'user2@example.com';

  final product1 = Product(
    id: 1,
    title: 'Product 1',
    price: 10.0,
    description: '',
    category: '',
    image: '',
    rating: Rating(rate: 4.5, count: 10),
  );
  final product2 = Product(
    id: 2,
    title: 'Product 2',
    price: 20.0,
    description: '',
    category: '',
    image: '',
    rating: Rating(rate: 4.0, count: 5),
  );

  final user1CartItem1 = CartItem(
    id: 'item1_user1',
    product: product1,
    quantity: 1,
  );
  final user2CartItem1 = CartItem(
    id: 'item1_user2',
    product: product2,
    quantity: 5,
  );

  setUp(() async {
    // Create an in-memory database for each test
    database = await databaseFactory.openDatabase(inMemoryDatabasePath);
    await database.execute('''
      CREATE TABLE ${DatabaseHelper.cartTableName}(
        id TEXT PRIMARY KEY,
        user_email TEXT NOT NULL,
        product_json TEXT NOT NULL,
        quantity INTEGER NOT NULL
      )
    ''');

    mockDatabaseHelper = MockDatabaseHelper();
    // Stub the database getter to return our in-memory database instance
    when(mockDatabaseHelper.database).thenAnswer((_) async => database);

    dataSource = CartLocalDataSourceImpl(mockDatabaseHelper);
  });

  tearDown(() async {
    await database.close();
  });

  group('CartLocalDataSourceImpl', () {
    test(
      'saveCartItem and getCartItems should only retrieve items for the correct user',
      () async {
        // Act
        await dataSource.saveCartItem(user1CartItem1, user1Email);

        // Assert
        final user1Items = await dataSource.getCartItems(user1Email);
        final user2Items = await dataSource.getCartItems(user2Email);

        expect(user1Items.length, 1);
        expect(user1Items.first.id, user1CartItem1.id);
        expect(user2Items.isEmpty, isTrue);
      },
    );

    test(
      'updateCartItem should only update the item for the correct user',
      () async {
        // Arrange
        await dataSource.saveCartItem(user1CartItem1, user1Email);
        final updatedItem = user1CartItem1.copyWith(quantity: 10);

        // Act
        await dataSource.updateCartItem(updatedItem, user1Email);

        // Assert
        final user1Items = await dataSource.getCartItems(user1Email);
        expect(user1Items.first.quantity, 10);
      },
    );

    test(
      'deleteCartItem should only delete the item for the correct user',
      () async {
        // Arrange
        await dataSource.saveCartItem(user1CartItem1, user1Email);
        await dataSource.saveCartItem(user2CartItem1, user2Email);

        // Act
        await dataSource.deleteCartItem(user1CartItem1.id, user1Email);

        // Assert
        final user1Items = await dataSource.getCartItems(user1Email);
        final user2Items = await dataSource.getCartItems(user2Email);

        expect(user1Items.isEmpty, isTrue);
        expect(user2Items.isNotEmpty, isTrue); // User 2's item should remain
      },
    );

    test('clearCart should only clear items for the specified user', () async {
      // Arrange
      await dataSource.saveCartItem(user1CartItem1, user1Email);
      await dataSource.saveCartItem(
        user1CartItem1.copyWith(id: 'item2_user1'),
        user1Email,
      );
      await dataSource.saveCartItem(user2CartItem1, user2Email);

      // Act
      await dataSource.clearCart(user1Email);

      // Assert
      final user1Items = await dataSource.getCartItems(user1Email);
      final user2Items = await dataSource.getCartItems(user2Email);

      expect(user1Items.isEmpty, isTrue);
      expect(user2Items.length, 1); // User 2's cart should be unaffected
      expect(user2Items.first.id, user2CartItem1.id);
    });
  });
}
