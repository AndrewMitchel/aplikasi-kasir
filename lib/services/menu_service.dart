import '../database/database_helper.dart';
import '../models/category_model.dart';
import '../models/menu_model.dart';

class MenuService {
  static final DatabaseHelper _database =
      DatabaseHelper.instance;

  // ============================================================
  // SETTINGS
  // ============================================================

  static Future<Map<String, double>>
      getSettings() {
    return _database.getSettings();
  }

  static Future<void> updateSettings({
    required double taxPercentage,
    required double discountPercentage,
  }) {
    return _database.updateSettings(
      taxPercentage: taxPercentage,
      discountPercentage:
          discountPercentage,
    );
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  static Future<List<CategoryModel>>
      getCategories() async {
    final result =
        await _database.getCategories();

    return result
        .map(
          (data) =>
              CategoryModel.fromMap(
            data,
          ),
        )
        .toList();
  }

  static Future<int> addCategory({
    required String name,
    required String iconName,
    required int colorValue,
  }) {
    return _database.addCategory(
      name: name,
      iconName: iconName,
      colorValue: colorValue,
    );
  }

  static Future<int> updateCategory({
    required int id,
    required String name,
    required String iconName,
    required int colorValue,
  }) {
    return _database.updateCategory(
      id: id,
      name: name,
      iconName: iconName,
      colorValue: colorValue,
    );
  }

  static Future<int> deleteCategory(
    int id,
  ) {
    return _database.deleteCategory(
      id,
    );
  }

  // ============================================================
  // MENU
  // ============================================================

  static Future<List<MenuModel>>
      getMenuByCategory(
    int categoryId,
  ) async {
    final result =
        await _database
            .getMenuByCategory(
      categoryId,
    );

    return result
        .map(
          (data) =>
              MenuModel.fromMap(
            data,
          ),
        )
        .toList();
  }

  static Future<int> addMenu({
    required String name,
    required int price,
    required int categoryId,
  }) {
    return _database.addMenu(
      name: name,
      price: price,
      categoryId: categoryId,
    );
  }

  static Future<int> updateMenu({
    required int id,
    required String name,
    required int price,
    required int categoryId,
  }) {
    return _database.updateMenu(
      id: id,
      name: name,
      price: price,
      categoryId: categoryId,
    );
  }

  static Future<int> deleteMenu(
    int id,
  ) {
    return _database.deleteMenu(
      id,
    );
  }

  // ============================================================
  // TRANSACTION
  // ============================================================

  static Future<int> addTransaction({
    required int subtotal,
    required double discountPercentage,
    required int discountAmount,
    required double taxPercentage,
    required int taxAmount,
    required int total,
    required String paymentMethod,
    required int cashReceived,
    required int changeAmount,
    required String buyerName,
    required List<Map<String, dynamic>> items,
  }) {
    return _database.addTransaction(
      subtotal: subtotal,
      discountPercentage:
          discountPercentage,
      discountAmount:
          discountAmount,
      taxPercentage:
          taxPercentage,
      taxAmount:
          taxAmount,
      total: total,
      paymentMethod:
          paymentMethod,
      cashReceived:
          cashReceived,
      changeAmount:
          changeAmount,
      buyerName:
          buyerName,
      items: items,
    );
  }

  static Future<List<Map<String, dynamic>>>
      getTransactions() {
    return _database.getTransactions();
  }

  static Future<Map<String, dynamic>?>
      getTransactionById(
    int id,
  ) {
    return _database
        .getTransactionById(id);
  }
}