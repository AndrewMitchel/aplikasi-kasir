part of 'pos_page.dart';

// ============================================================
// DATABASE
// ============================================================

extension _PosPageLogic on _PosPageState {
  Future<void> _loadCategories() async {
    try {
      final result =
          await MenuService.getCategories();

      if (!mounted) {
        return;
      }

      setState(() {
        categories = result;
        isLoadingCategories = false;
      });

      if (categories.isNotEmpty) {
        await _selectCategory(
          categories.first.id,
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoadingCategories = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memuat kategori: $e',
          ),
        ),
      );
    }
  }

  Future<void> _loadSettings() async {
    try {
      final settings =
          await MenuService.getSettings();

      if (!mounted) {
        return;
      }

      setState(() {
        taxPercentage =
            settings['tax_percentage'] ?? 10.0;

        discountPercentage =
            settings['discount_percentage'] ?? 0.0;

        isLoadingSettings = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoadingSettings = false;
      });
    }
  }

  // ============================================================
  // STOCK
  // ============================================================

  Future<int> _getDisplayStock(
    int menuId,
  ) async {
    final db =
        await DatabaseHelper.instance.database;

    final result = await db.rawQuery(
      '''
      SELECT
        COALESCE(display_stock, 0) AS display_stock
      FROM inventory_stocks
      WHERE menu_id = ?
      LIMIT 1
      ''',
      [menuId],
    );

    if (result.isEmpty) {
      return 0;
    }

    return (result.first['display_stock'] as int?) ?? 0;
  }

  Future<bool> _checkCartStock(
    MenuModel menu,
    int requestedQuantity,
  ) async {
    final stock =
        await _getDisplayStock(menu.id);

    if (requestedQuantity <= stock) {
      return true;
    }

    if (!mounted) {
      return false;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Stok display ${menu.name} hanya tersisa $stock.',
        ),
      ),
    );

    return false;
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  Future<void> _openSettings() async {
    final result =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const SettingsPage(),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result == true) {
      await _loadSettings();
    }
  }

  // ============================================================
  // ACCOUNTING
  // ============================================================

  Future<void> _openAccounting() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AccountingPage(),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadSettings();
  }

  // ============================================================
  // MENU MANAGEMENT
  // ============================================================

  Future<void> _openMenuManagement() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const MenuManagementPage(),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadCategories();
  }

  // ============================================================
  // TRANSACTIONS
  // ============================================================

  Future<void> _openTransactions() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const TransactionPage(),
      ),
    );
  }

  // ============================================================
  // WAREHOUSE / GUDANG
  // ============================================================

  Future<void> _openWarehouse() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const WarehousePage(),
      ),
    );

    if (!mounted) {
      return;
    }

    // Refresh menu setelah kembali dari gudang.
    if (selectedCategoryId != null) {
      await _selectCategory(
        selectedCategoryId!,
      );
    }
  }

  // ============================================================
  // PAYMENT
  // ============================================================

  Future<void> _openPaymentPage() async {
    if (cart.isEmpty) {
      return;
    }

    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pilih metode pembayaran terlebih dahulu.',
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // CEK STOCK SEBELUM MASUK PEMBAYARAN
    // ==========================================================

    final stockAvailable =
        await _validateCartStock();

    if (!stockAvailable) {
      return;
    }

    // ==========================================================
    // CASH
    // ==========================================================

    if (selectedPaymentMethod == 'Cash') {
      final result =
          await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CashPaymentPage(
            totalAmount:
                total.toInt(),
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      if (result != null) {
        final buyerName =
            result['buyerName']
                    ?.toString() ??
                '';

        final cashReceived =
            result['cashReceived'] is int
                ? result['cashReceived']
                : int.tryParse(
                      result['cashReceived']
                              ?.toString() ??
                          '0',
                    ) ??
                    0;

        final changeAmount =
            result['change'] is int
                ? result['change']
                : int.tryParse(
                      result['change']
                              ?.toString() ??
                          '0',
                    ) ??
                    0;

        await _saveCompletedTransaction(
          paymentMethod: 'Cash',
          cashReceived:
              cashReceived,
          changeAmount:
              changeAmount,
          buyerName:
              buyerName,
        );
      }

      return;
    }

    // ==========================================================
    // DEBIT CARD
    // ==========================================================

    if (selectedPaymentMethod == 'Debit Card' ||
        selectedPaymentMethod == 'Card') {
      final result =
          await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PaymentPage(
            totalAmount:
                total.toInt(),
            paymentMethod:
                'Debit Card',
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      if (result != null) {
        final buyerName =
            result['buyerName']
                    ?.toString() ??
                '';

        await _saveCompletedTransaction(
          paymentMethod:
              'Debit Card',
          buyerName:
              buyerName,
        );
      }

      return;
    }

    // ==========================================================
    // E-WALLET / QR
    // ==========================================================

    if (selectedPaymentMethod == 'E-Wallet' ||
        selectedPaymentMethod == 'QR') {
      final result =
          await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PaymentPage(
            totalAmount:
                total.toInt(),
            paymentMethod:
                'E-Wallet',
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      if (result != null) {
        final buyerName =
            result['buyerName']
                    ?.toString() ??
                '';

        await _saveCompletedTransaction(
          paymentMethod:
              'E-Wallet',
          buyerName:
              buyerName,
        );
      }

      return;
    }
  }

  // ============================================================
  // VALIDATE CART STOCK
  // ============================================================

  Future<bool> _validateCartStock() async {
    for (final item in cart) {
      if (item.menuId == null) {
        if (!mounted) {
          return false;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ID menu ${item.name} tidak ditemukan.',
            ),
          ),
        );

        return false;
      }

      final stock =
          await _getDisplayStock(
        item.menuId!,
      );

      if (item.quantity > stock) {
        if (!mounted) {
          return false;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Stok display ${item.name} hanya $stock, sedangkan pesanan ${item.quantity}.',
            ),
          ),
        );

        return false;
      }
    }

    return true;
  }

  // ============================================================
  // REDUCE DISPLAY STOCK
  // ============================================================

  Future<bool> _reduceDisplayStock() async {
    final db =
        await DatabaseHelper.instance.database;

    try {
      await db.transaction(
        (txn) async {
          for (final item in cart) {
            if (item.menuId == null) {
              throw Exception(
                'ID menu ${item.name} tidak ditemukan.',
              );
            }

            final changed =
                await txn.rawUpdate(
              '''
              UPDATE inventory_stocks
              SET display_stock =
                  display_stock - ?
              WHERE menu_id = ?
                AND display_stock >= ?
              ''',
              [
                item.quantity,
                item.menuId,
                item.quantity,
              ],
            );

            if (changed == 0) {
              throw Exception(
                'Stok display ${item.name} tidak mencukupi.',
              );
            }
          }
        },
      );

      return true;
    } catch (e) {
      if (!mounted) {
        return false;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stok tidak dapat dikurangi: $e',
          ),
        ),
      );

      return false;
    }
  }

  // ============================================================
  // SAVE COMPLETED TRANSACTION
  // ============================================================

  Future<void> _saveCompletedTransaction({
    required String paymentMethod,
    int cashReceived = 0,
    int changeAmount = 0,
    String buyerName = '',
  }) async {
    final transactionItems =
        cart.map(
      (item) {
        return {
          'menuId': item.menuId,
          'name': item.name,
          'price': item.price,
          'quantity': item.quantity,
        };
      },
    ).toList();

    try {
      // ========================================================
      // CEK ULANG STOCK
      // ========================================================

      final stockAvailable =
          await _validateCartStock();

      if (!stockAvailable) {
        return;
      }

      // ========================================================
      // KURANGI DISPLAY STOCK
      // ========================================================

      final stockReduced =
          await _reduceDisplayStock();

      if (!stockReduced) {
        return;
      }

      // ========================================================
      // SIMPAN TRANSAKSI
      //
      // Database mengembalikan ID transaksi yang baru dibuat.
      // ID ini nantinya dipakai untuk mengambil data struk.
      // ========================================================

      final transactionId =
          await MenuService.addTransaction(
        subtotal:
            subtotal.toInt(),
        discountPercentage:
            discountPercentage,
        discountAmount:
            discountAmount.toInt(),
        taxPercentage:
            taxPercentage,
        taxAmount:
            taxAmount.toInt(),
        total:
            total.toInt(),
        paymentMethod:
            paymentMethod,
        cashReceived:
            cashReceived,
        changeAmount:
            changeAmount,
        buyerName:
            buyerName,
        items:
            transactionItems,
      );

      if (!mounted) {
        return;
      }

      // ========================================================
      // KOSONGKAN CART
      // ========================================================

      setState(() {
        cart.clear();
        selectedPaymentMethod = null;
      });

      // ========================================================
      // BUKA HALAMAN STRUK
      // ========================================================

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ReceiptPage(
            transactionId:
                transactionId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pembayaran berhasil, tetapi transaksi gagal disimpan: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // SELECT CATEGORY
  // ============================================================

  Future<void> _selectCategory(
    int categoryId,
  ) async {
    setState(() {
      selectedCategoryId =
          categoryId;

      isLoadingMenu = true;
    });

    try {
      final result =
          await MenuService.getMenuByCategory(
        categoryId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        menuItems = result;
        isLoadingMenu = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        menuItems = [];
        isLoadingMenu = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memuat menu: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // CATEGORY ICON
  // ============================================================

  IconData _getCategoryIcon(
    String iconName,
  ) {
    switch (iconName) {
      case 'coffee':
        return Icons.local_cafe_outlined;

      case 'non_coffee':
        return Icons.local_drink_outlined;

      case 'fresh':
        return Icons.local_bar_outlined;

      case 'tea':
        return Icons.emoji_food_beverage_outlined;

      case 'main_course':
        return Icons.restaurant_outlined;

      case 'snack':
        return Icons.fastfood_outlined;

      case 'grill':
        return Icons.outdoor_grill_outlined;

      default:
        return Icons.category_outlined;
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  List<MenuModel> get filteredMenuItems {
    if (searchQuery.trim().isEmpty) {
      return menuItems;
    }

    final query =
        searchQuery.trim().toLowerCase();

    return menuItems.where(
      (menu) {
        return menu.name
            .toLowerCase()
            .contains(query);
      },
    ).toList();
  }

  // ============================================================
  // CART
  // ============================================================

  double get subtotal {
    return cart.fold(
      0,
      (total, item) =>
          total +
          (item.price *
              item.quantity),
    );
  }

  double get discountAmount {
    return subtotal *
        (discountPercentage / 100);
  }

  double get afterDiscount {
    return subtotal -
        discountAmount;
  }

  double get taxAmount {
    return afterDiscount *
        (taxPercentage / 100);
  }

  double get total {
    return afterDiscount +
        taxAmount;
  }

  int get totalCartItems {
    return cart.fold(
      0,
      (total, item) =>
          total +
          item.quantity,
    );
  }

  // ============================================================
  // ADD MENU TO CART
  // ============================================================

  Future<void> _addMenuToCart(
    MenuModel menu,
  ) async {
    final currentQuantity =
        _getCartQuantity(menu);

    final requestedQuantity =
        currentQuantity + 1;

    final available =
        await _checkCartStock(
      menu,
      requestedQuantity,
    );

    if (!available) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      final index =
          cart.indexWhere(
        (item) =>
            item.name == menu.name,
      );

      if (index >= 0) {
        cart[index].quantity++;
      } else {
        cart.add(
          CartItem(
            menuId: menu.id,
            name: menu.name,
            price: menu.price,
            quantity: 1,
          ),
        );
      }
    });
  }

  // ============================================================
  // REMOVE MENU FROM CART
  // ============================================================

  void _removeMenuFromCart(
    MenuModel menu,
  ) {
    setState(() {
      final index =
          cart.indexWhere(
        (item) =>
            item.name == menu.name,
      );

      if (index >= 0) {
        if (cart[index].quantity > 1) {
          cart[index].quantity--;
        } else {
          cart.removeAt(index);
        }
      }
    });
  }

  // ============================================================
  // GET CART QUANTITY
  // ============================================================

  int _getCartQuantity(
    MenuModel menu,
  ) {
    final index =
        cart.indexWhere(
      (item) =>
          item.name == menu.name,
    );

    if (index >= 0) {
      return cart[index].quantity;
    }

    return 0;
  }

  // ============================================================
  // INCREASE CART ITEM
  // ============================================================

  Future<void> _increaseCartItem(
    CartItem item,
  ) async {
    if (item.menuId == null) {
      return;
    }

    final stock =
        await _getDisplayStock(
      item.menuId!,
    );

    if (item.quantity + 1 > stock) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stok display ${item.name} hanya $stock.',
          ),
        ),
      );

      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      final index =
          cart.indexWhere(
        (cartItem) =>
            cartItem.name == item.name,
      );

      if (index >= 0) {
        cart[index].quantity++;
      }
    });
  }

  // ============================================================
  // DECREASE CART ITEM
  // ============================================================

  void _decreaseCartItem(
    CartItem item,
  ) {
    setState(() {
      final index =
          cart.indexWhere(
        (cartItem) =>
            cartItem.name == item.name,
      );

      if (index >= 0) {
        if (cart[index].quantity > 1) {
          cart[index].quantity--;
        } else {
          cart.removeAt(index);
        }
      }
    });
  }

  // ============================================================
  // RUPIAH
  // ============================================================

  String _formatRupiah(
    int value,
  ) {
    final number =
        value.toString();

    String result = '';
    int count = 0;

    for (
      int i = number.length - 1;
      i >= 0;
      i--
    ) {
      result =
          number[i] + result;

      count++;

      if (count == 3 && i != 0) {
        result =
            '.$result';

        count = 0;
      }
    }

    return result;
  }

  String _formatPercentage(
    double value,
  ) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }
}

// ============================================================
// CART MODEL
// ============================================================

class CartItem {
  final int? menuId;
  final String name;
  final int price;
  int quantity;

  CartItem({
    required this.menuId,
    required this.name,
    required this.price,
    required this.quantity,
  });
}