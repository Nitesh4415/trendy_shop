import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shop_trendy/core/utils/extensions/product/product_extension.dart';
import 'package:shop_trendy/core/utils/extensions/product/product_model_extension.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../product/data/models/product_model.dart';
import '../../domain/entities/cart_item.dart';
import 'cart_local_datasource.dart';

@LazySingleton(as: CartLocalDataSource)
class CartLocalDataSourceImpl implements CartLocalDataSource {
  final DatabaseHelper _databaseHelper;

  CartLocalDataSourceImpl(this._databaseHelper);

  // Helper method to convert CartItem to a Map for SQLite.
  // It now includes the user's email.
  Map<String, dynamic> _toMap(CartItem item, String userEmail) {
    return {
      'id': item.id,
      'user_email': userEmail, // Add user email to the map
      'product_json': jsonEncode(item.product.toModel().toJson()),
      'quantity': item.quantity,
    };
  }

  // Helper method to convert a Map from SQLite to CartItem.
  CartItem _fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as String,
      product: ProductModel.fromJson(
        jsonDecode(map['product_json'] as String),
      ).toEntity(),
      quantity: map['quantity'] as int,
    );
  }

  // --- All methods below now require userEmail ---

  @override
  Future<List<CartItem>> getCartItems(String userEmail) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.cartTableName,
      where: 'user_email = ?', // Filter by email
      whereArgs: [userEmail],
    );
    return List.generate(maps.length, (i) {
      return _fromMap(maps[i]);
    });
  }

  @override
  Future<void> saveCartItem(CartItem item, String userEmail) async {
    final db = await _databaseHelper.database;
    await db.insert(
      DatabaseHelper.cartTableName,
      _toMap(item, userEmail), // Pass email to the helper
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateCartItem(CartItem item, String userEmail) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseHelper.cartTableName,
      _toMap(item, userEmail),
      where:
          'id = ? AND user_email = ?', // Ensure we only update the item for the correct user
      whereArgs: [item.id, userEmail],
    );
  }

  @override
  Future<void> deleteCartItem(String id, String userEmail) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseHelper.cartTableName,
      where:
          'id = ? AND user_email = ?', // Ensure we only delete the item for the correct user
      whereArgs: [id, userEmail],
    );
  }

  @override
  Future<void> clearCart(String userEmail) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseHelper.cartTableName,
      where: 'user_email = ?', // Only clear the cart for the specified user
      whereArgs: [userEmail],
    );
  }
}
