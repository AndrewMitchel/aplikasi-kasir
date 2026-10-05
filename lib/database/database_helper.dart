import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance =
      DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath =
        await getDatabasesPath();

    final path = join(
      databasesPath,
      'aplikasi_kasir.db',
    );

    return openDatabase(
      path,

      // ========================================================
      // VERSION 4
      // ========================================================
      //
      // Version 3 = transaksi
      // Version 4 = stok gudang + stok display
      //
      version: 4,

      onConfigure: (db) async {
        await db.execute(
          'PRAGMA foreign_keys = ON',
        );
      },

      onCreate: (db, version) async {
        await _createTables(db);

        await _insertInitialSettings(db);

        await _insertInitialData(db);
      },

      onUpgrade: (
        db,
        oldVersion,
        newVersion,
      ) async {
        // ======================================================
        // VERSION 2
        // ======================================================

        if (oldVersion < 2) {
          await _createSettingsTable(
            db,
          );

          await _insertInitialSettings(
            db,
          );
        }

        // ======================================================
        // VERSION 3
        // ======================================================

        if (oldVersion < 3) {
          await _createTransactionsTable(
            db,
          );
        }

        // ======================================================
        // VERSION 4
        // INVENTORY / GUDANG
        // ======================================================

        if (oldVersion < 4) {
          await _createInventoryTable(
            db,
          );
        }
      },
    );
  }

  // ============================================================
  // CREATE TABLE
  // ============================================================

  Future<void> _createTables(
    Database db,
  ) async {
    // ==========================================================
    // CATEGORIES
    // ==========================================================

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        icon_name TEXT NOT NULL,
        color_value INTEGER NOT NULL
      )
    ''');

    // ==========================================================
    // MENU ITEMS
    // ==========================================================

    await db.execute('''
      CREATE TABLE menu_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        FOREIGN KEY (category_id)
          REFERENCES categories(id)
          ON DELETE CASCADE
      )
    ''');

    // ==========================================================
    // SETTINGS
    // ==========================================================

    await _createSettingsTable(
      db,
    );

    // ==========================================================
    // TRANSACTIONS
    // ==========================================================

    await _createTransactionsTable(
      db,
    );

    // ==========================================================
    // INVENTORY
    // ==========================================================

    await _createInventoryTable(
      db,
    );
  }

  // ============================================================
  // SETTINGS TABLE
  // ============================================================

  Future<void> _createSettingsTable(
    Database db,
  ) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        id INTEGER PRIMARY KEY,
        tax_percentage REAL NOT NULL DEFAULT 10,
        discount_percentage REAL NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _insertInitialSettings(
    Database db,
  ) async {
    await db.insert(
      'settings',
      {
        'id': 1,
        'tax_percentage': 10.0,
        'discount_percentage': 0.0,
      },
      conflictAlgorithm:
          ConflictAlgorithm.ignore,
    );
  }

  // ============================================================
  // TRANSACTIONS TABLE
  // ============================================================

  Future<void> _createTransactionsTable(
    Database db,
  ) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subtotal INTEGER NOT NULL,
        discount_percentage REAL NOT NULL DEFAULT 0,
        discount_amount INTEGER NOT NULL DEFAULT 0,
        tax_percentage REAL NOT NULL DEFAULT 0,
        tax_amount INTEGER NOT NULL DEFAULT 0,
        total INTEGER NOT NULL,
        payment_method TEXT NOT NULL,
        cash_received INTEGER NOT NULL DEFAULT 0,
        change_amount INTEGER NOT NULL DEFAULT 0,
        buyer_name TEXT NOT NULL DEFAULT '',
        items_json TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // ============================================================
  // INVENTORY TABLE
  // ============================================================

  Future<void> _createInventoryTable(
    Database db,
  ) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS inventory_stocks (
        menu_id INTEGER PRIMARY KEY,
        warehouse_stock INTEGER NOT NULL DEFAULT 0,
        display_stock INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (menu_id)
          REFERENCES menu_items(id)
          ON DELETE CASCADE
      )
    ''');
  }

  // ============================================================
  // ADD TRANSACTION
  // ============================================================

  Future<int> addTransaction({
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
  }) async {
    final db = await database;

    return db.insert(
      'transactions',
      {
        'subtotal': subtotal,
        'discount_percentage':
            discountPercentage,
        'discount_amount':
            discountAmount,
        'tax_percentage':
            taxPercentage,
        'tax_amount':
            taxAmount,
        'total': total,
        'payment_method':
            paymentMethod,
        'cash_received':
            cashReceived,
        'change_amount':
            changeAmount,
        'buyer_name':
            buyerName,
        'items_json':
            jsonEncode(items),
        'created_at':
            DateTime.now()
                .toIso8601String(),
      },
    );
  }

  // ============================================================
  // GET TRANSACTIONS
  // ============================================================

  Future<List<Map<String, dynamic>>>
      getTransactions() async {
    final db = await database;

    return db.query(
      'transactions',
      orderBy: 'id DESC',
    );
  }

  // ============================================================
  // GET TRANSACTION BY ID
  // ============================================================

  Future<Map<String, dynamic>?>
      getTransactionById(
    int id,
  ) async {
    final db = await database;

    final result = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  // ============================================================
  // DATA AWAL
  // ============================================================

  Future<void> _insertInitialData(
    Database db,
  ) async {
    final categories = [
      {
        'name': 'Coffee',
        'icon_name': 'coffee',
        'color_value': 0xFFD2E1DF,
      },
      {
        'name': 'Non Coffee',
        'icon_name': 'non_coffee',
        'color_value': 0xFFE1C8EA,
      },
      {
        'name': 'Fresh',
        'icon_name': 'fresh',
        'color_value': 0xFFBCD9E9,
      },
      {
        'name': 'Tea Series',
        'icon_name': 'tea',
        'color_value': 0xFFC4C5EA,
      },
      {
        'name': 'Main Course',
        'icon_name': 'main_course',
        'color_value': 0xFFF2B8D0,
      },
      {
        'name': 'Snack',
        'icon_name': 'snack',
        'color_value': 0xFFE5D7DB,
      },
      {
        'name': 'Grill',
        'icon_name': 'grill',
        'color_value': 0xFFE8BFC6,
      },
    ];

    for (final category in categories) {
      await db.insert(
        'categories',
        category,
        conflictAlgorithm:
            ConflictAlgorithm.ignore,
      );
    }

    final categoryRows =
        await db.query('categories');

    final categoryIds =
        <String, int>{};

    for (final row in categoryRows) {
      categoryIds[
              row['name'] as String] =
          row['id'] as int;
    }

    final menus = [
      // ========================================================
      // COFFEE
      // ========================================================

      {
        'name': 'Americano',
        'price': 18000,
        'category_id':
            categoryIds['Coffee'],
      },
      {
        'name': 'Cappuccino',
        'price': 22000,
        'category_id':
            categoryIds['Coffee'],
      },
      {
        'name': 'Cafe Latte',
        'price': 23000,
        'category_id':
            categoryIds['Coffee'],
      },
      {
        'name': 'Caramel Latte',
        'price': 25000,
        'category_id':
            categoryIds['Coffee'],
      },
      {
        'name': 'Vanilla Latte',
        'price': 25000,
        'category_id':
            categoryIds['Coffee'],
      },
      {
        'name': 'Mocha',
        'price': 26000,
        'category_id':
            categoryIds['Coffee'],
      },
      {
        'name': 'Hazelnut Coffee',
        'price': 26000,
        'category_id':
            categoryIds['Coffee'],
      },
      {
        'name': 'Espresso',
        'price': 15000,
        'category_id':
            categoryIds['Coffee'],
      },

      // ========================================================
      // NON COFFEE
      // ========================================================

      {
        'name': 'Chocolate',
        'price': 22000,
        'category_id':
            categoryIds['Non Coffee'],
      },
      {
        'name': 'Red Velvet',
        'price': 24000,
        'category_id':
            categoryIds['Non Coffee'],
      },
      {
        'name': 'Matcha Latte',
        'price': 25000,
        'category_id':
            categoryIds['Non Coffee'],
      },
      {
        'name': 'Taro Latte',
        'price': 23000,
        'category_id':
            categoryIds['Non Coffee'],
      },
      {
        'name': 'Vanilla Milk',
        'price': 20000,
        'category_id':
            categoryIds['Non Coffee'],
      },
      {
        'name': 'Strawberry Milk',
        'price': 22000,
        'category_id':
            categoryIds['Non Coffee'],
      },
      {
        'name': 'Cookies Cream',
        'price': 24000,
        'category_id':
            categoryIds['Non Coffee'],
      },
      {
        'name': 'Milkshake',
        'price': 26000,
        'category_id':
            categoryIds['Non Coffee'],
      },

      // ========================================================
      // FRESH
      // ========================================================

      {
        'name': 'Orange Juice',
        'price': 18000,
        'category_id':
            categoryIds['Fresh'],
      },
      {
        'name': 'Apple Juice',
        'price': 18000,
        'category_id':
            categoryIds['Fresh'],
      },
      {
        'name': 'Mango Juice',
        'price': 20000,
        'category_id':
            categoryIds['Fresh'],
      },
      {
        'name': 'Watermelon Juice',
        'price': 18000,
        'category_id':
            categoryIds['Fresh'],
      },
      {
        'name': 'Lemon Squash',
        'price': 20000,
        'category_id':
            categoryIds['Fresh'],
      },
      {
        'name': 'Strawberry Fresh',
        'price': 22000,
        'category_id':
            categoryIds['Fresh'],
      },
      {
        'name': 'Lychee Squash',
        'price': 22000,
        'category_id':
            categoryIds['Fresh'],
      },
      {
        'name': 'Pineapple Juice',
        'price': 20000,
        'category_id':
            categoryIds['Fresh'],
      },

      // ========================================================
      // TEA SERIES
      // ========================================================

      {
        'name': 'Original Tea',
        'price': 12000,
        'category_id':
            categoryIds['Tea Series'],
      },
      {
        'name': 'Lemon Tea',
        'price': 15000,
        'category_id':
            categoryIds['Tea Series'],
      },
      {
        'name': 'Lychee Tea',
        'price': 18000,
        'category_id':
            categoryIds['Tea Series'],
      },
      {
        'name': 'Peach Tea',
        'price': 18000,
        'category_id':
            categoryIds['Tea Series'],
      },
      {
        'name': 'Thai Tea',
        'price': 20000,
        'category_id':
            categoryIds['Tea Series'],
      },
      {
        'name': 'Milk Tea',
        'price': 20000,
        'category_id':
            categoryIds['Tea Series'],
      },
      {
        'name': 'Green Tea',
        'price': 15000,
        'category_id':
            categoryIds['Tea Series'],
      },
      {
        'name': 'Earl Grey Tea',
        'price': 18000,
        'category_id':
            categoryIds['Tea Series'],
      },

      // ========================================================
      // MAIN COURSE
      // ========================================================

      {
        'name': 'Chicken Steak',
        'price': 35000,
        'category_id':
            categoryIds['Main Course'],
      },
      {
        'name': 'Beef Steak',
        'price': 45000,
        'category_id':
            categoryIds['Main Course'],
      },
      {
        'name': 'Chicken Rice',
        'price': 28000,
        'category_id':
            categoryIds['Main Course'],
      },
      {
        'name': 'Fried Rice',
        'price': 25000,
        'category_id':
            categoryIds['Main Course'],
      },
      {
        'name': 'Spaghetti Carbonara',
        'price': 30000,
        'category_id':
            categoryIds['Main Course'],
      },
      {
        'name': 'Spaghetti Bolognese',
        'price': 30000,
        'category_id':
            categoryIds['Main Course'],
      },
      {
        'name': 'Chicken Katsu',
        'price': 30000,
        'category_id':
            categoryIds['Main Course'],
      },
      {
        'name': 'Fish and Chips',
        'price': 32000,
        'category_id':
            categoryIds['Main Course'],
      },

      // ========================================================
      // SNACK
      // ========================================================

      {
        'name': 'French Fries',
        'price': 18000,
        'category_id':
            categoryIds['Snack'],
      },
      {
        'name': 'Chicken Wings',
        'price': 22000,
        'category_id':
            categoryIds['Snack'],
      },
      {
        'name': 'Onion Rings',
        'price': 18000,
        'category_id':
            categoryIds['Snack'],
      },
      {
        'name': 'Cheese Fries',
        'price': 22000,
        'category_id':
            categoryIds['Snack'],
      },
      {
        'name': 'Nachos',
        'price': 20000,
        'category_id':
            categoryIds['Snack'],
      },
      {
        'name': 'Pisang Goreng',
        'price': 18000,
        'category_id':
            categoryIds['Snack'],
      },
      {
        'name': 'Roti Bakar',
        'price': 20000,
        'category_id':
            categoryIds['Snack'],
      },
      {
        'name': 'Cireng',
        'price': 15000,
        'category_id':
            categoryIds['Snack'],
      },

      // ========================================================
      // GRILL
      // ========================================================

      {
        'name': 'Grilled Chicken',
        'price': 35000,
        'category_id':
            categoryIds['Grill'],
      },
      {
        'name': 'Grilled Beef',
        'price': 45000,
        'category_id':
            categoryIds['Grill'],
      },
      {
        'name': 'Grilled Sausage',
        'price': 28000,
        'category_id':
            categoryIds['Grill'],
      },
      {
        'name': 'Grilled Squid',
        'price': 32000,
        'category_id':
            categoryIds['Grill'],
      },
      {
        'name': 'Grilled Prawn',
        'price': 40000,
        'category_id':
            categoryIds['Grill'],
      },
      {
        'name': 'Grilled Fish',
        'price': 35000,
        'category_id':
            categoryIds['Grill'],
      },
      {
        'name': 'Beef Ribs',
        'price': 50000,
        'category_id':
            categoryIds['Grill'],
      },
      {
        'name': 'Mixed Grill',
        'price': 55000,
        'category_id':
            categoryIds['Grill'],
      },
    ];

    for (final menu in menus) {
      await db.insert(
        'menu_items',
        menu,
      );
    }
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  Future<Map<String, double>>
      getSettings() async {
    final db = await database;

    final result = await db.query(
      'settings',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isEmpty) {
      await _insertInitialSettings(
        db,
      );

      return {
        'tax_percentage': 10.0,
        'discount_percentage': 0.0,
      };
    }

    final row = result.first;

    return {
      'tax_percentage':
          (row['tax_percentage']
                  as num)
              .toDouble(),
      'discount_percentage':
          (row['discount_percentage']
                  as num)
              .toDouble(),
    };
  }

  Future<void> updateSettings({
    required double taxPercentage,
    required double discountPercentage,
  }) async {
    final db = await database;

    await db.insert(
      'settings',
      {
        'id': 1,
        'tax_percentage':
            taxPercentage,
        'discount_percentage':
            discountPercentage,
      },
      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  Future<List<Map<String, dynamic>>>
      getCategories() async {
    final db = await database;

    return db.rawQuery('''
      SELECT
        c.id,
        c.name,
        c.icon_name,
        c.color_value,
        COUNT(m.id) AS item_count
      FROM categories c
      LEFT JOIN menu_items m
        ON m.category_id = c.id
      GROUP BY
        c.id,
        c.name,
        c.icon_name,
        c.color_value
      ORDER BY c.id ASC
    ''');
  }

  Future<int> addCategory({
    required String name,
    required String iconName,
    required int colorValue,
  }) async {
    final db = await database;

    return db.insert(
      'categories',
      {
        'name': name,
        'icon_name':
            iconName,
        'color_value':
            colorValue,
      },
    );
  }

  Future<int> updateCategory({
    required int id,
    required String name,
    required String iconName,
    required int colorValue,
  }) async {
    final db = await database;

    return db.update(
      'categories',
      {
        'name': name,
        'icon_name':
            iconName,
        'color_value':
            colorValue,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCategory(
    int id,
  ) async {
    final db = await database;

    return db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // MENU
  // ============================================================

  Future<List<Map<String, dynamic>>>
      getMenuByCategory(
    int categoryId,
  ) async {
    final db = await database;

    return db.query(
      'menu_items',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'id ASC',
    );
  }

  Future<int> addMenu({
    required String name,
    required int price,
    required int categoryId,
  }) async {
    final db = await database;

    return db.insert(
      'menu_items',
      {
        'name': name,
        'price': price,
        'category_id':
            categoryId,
      },
    );
  }

  Future<int> updateMenu({
    required int id,
    required String name,
    required int price,
    required int categoryId,
  }) async {
    final db = await database;

    return db.update(
      'menu_items',
      {
        'name': name,
        'price': price,
        'category_id':
            categoryId,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteMenu(
    int id,
  ) async {
    final db = await database;

    return db.delete(
      'menu_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // INVENTORY / GUDANG
  // ============================================================

  Future<List<Map<String, dynamic>>>
      getWarehouseProducts() async {
    final db = await database;

    return db.rawQuery('''
      SELECT
        m.id AS menu_id,
        m.name AS name,
        m.price AS price,
        c.name AS category_name,
        COALESCE(
          i.warehouse_stock,
          0
        ) AS warehouse_stock,
        COALESCE(
          i.display_stock,
          0
        ) AS display_stock
      FROM menu_items m
      LEFT JOIN categories c
        ON c.id = m.category_id
      LEFT JOIN inventory_stocks i
        ON i.menu_id = m.id
      ORDER BY
        c.name COLLATE NOCASE ASC,
        m.name COLLATE NOCASE ASC
    ''');
  }

  Future<void> addWarehouseStock({
    required int menuId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      return;
    }

    final db = await database;

    await db.transaction(
      (txn) async {
        await txn.rawInsert('''
          INSERT OR IGNORE INTO inventory_stocks (
            menu_id,
            warehouse_stock,
            display_stock
          )
          VALUES (?, 0, 0)
        ''', [
          menuId,
        ]);

        await txn.rawUpdate('''
          UPDATE inventory_stocks
          SET warehouse_stock =
              warehouse_stock + ?
          WHERE menu_id = ?
        ''', [
          quantity,
          menuId,
        ]);
      },
    );
  }

  Future<bool> transferStockToDisplay({
    required int menuId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      return false;
    }

    final db = await database;

    bool success = false;

    await db.transaction(
      (txn) async {
        await txn.rawInsert('''
          INSERT OR IGNORE INTO inventory_stocks (
            menu_id,
            warehouse_stock,
            display_stock
          )
          VALUES (?, 0, 0)
        ''', [
          menuId,
        ]);

        final changed =
            await txn.rawUpdate('''
          UPDATE inventory_stocks
          SET
            warehouse_stock =
                warehouse_stock - ?,
            display_stock =
                display_stock + ?
          WHERE menu_id = ?
            AND warehouse_stock >= ?
        ''', [
          quantity,
          quantity,
          menuId,
          quantity,
        ]);

        success =
            changed > 0;
      },
    );

    return success;
  }

  Future<bool> transferStockToWarehouse({
    required int menuId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      return false;
    }

    final db = await database;

    bool success = false;

    await db.transaction(
      (txn) async {
        await txn.rawInsert('''
          INSERT OR IGNORE INTO inventory_stocks (
            menu_id,
            warehouse_stock,
            display_stock
          )
          VALUES (?, 0, 0)
        ''', [
          menuId,
        ]);

        final changed =
            await txn.rawUpdate('''
          UPDATE inventory_stocks
          SET
            warehouse_stock =
                warehouse_stock + ?,
            display_stock =
                display_stock - ?
          WHERE menu_id = ?
            AND display_stock >= ?
        ''', [
          quantity,
          quantity,
          menuId,
          quantity,
        ]);

        success =
            changed > 0;
      },
    );

    return success;
  }
}