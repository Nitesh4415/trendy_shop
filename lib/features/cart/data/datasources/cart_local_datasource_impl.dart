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
  Map<String, dynamic> _toMap(CartItem item) {
    return {
      'id': item.id,
      // Convert Product entity to ProductModel, then to JSON string
      'product_json': jsonEncode(item.product.toModel().toJson()),
      'quantity': item.quantity,
    };
  }

  // Helper method to convert a Map from SQLite to CartItem.
  CartItem _fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as String,
      // Parse Product from JSON string, then convert ProductModel to Product entity
      product: ProductModel.fromJson(jsonDecode(map['product_json'] as String)).toEntity(),
      quantity: map['quantity'] as int,
    );
  }

  @override
  Future<List<CartItem>> getCartItems() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseHelper.cartTableName);
    return List.generate(maps.length, (i) {
      return _fromMap(maps[i]);
    });
  }

  @override
  Future<void> saveCartItem(CartItem item) async {
    final db = await _databaseHelper.database;
    await db.insert(
      DatabaseHelper.cartTableName,
      _toMap(item),
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace if item with same ID exists
    );
  }

  @override
  Future<void> updateCartItem(CartItem item) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseHelper.cartTableName,
      _toMap(item),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  @override
  Future<void> deleteCartItem(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseHelper.cartTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> clearCart() async {
    final db = await _databaseHelper.database;
    await db.delete(DatabaseHelper.cartTableName);
  }
}