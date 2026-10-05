import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class WarehousePage extends StatefulWidget {
  const WarehousePage({super.key});

  @override
  State<WarehousePage> createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage> {
  final DatabaseHelper _database = DatabaseHelper.instance;

  final TextEditingController _searchController =
      TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  List<Map<String, dynamic>> products = [];

  bool isLoading = true;

  String searchQuery = '';

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }

  // ============================================================
  // HELPER
  // ============================================================

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  // ============================================================
  // TOTAL STOCK
  // ============================================================

  int get totalWarehouseStock {
    return products.fold(
      0,
      (total, item) {
        return total +
            _toInt(
              item['warehouse_stock'],
            );
      },
    );
  }

  int get totalDisplayStock {
    return products.fold(
      0,
      (total, item) {
        return total +
            _toInt(
              item['display_stock'],
            );
      },
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<Map<String, dynamic>> get filteredProducts {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return products;
    }

    return products.where((product) {
      final name =
          (product['name'] ?? '')
              .toString()
              .toLowerCase();

      final category =
          (product['category_name'] ?? '')
              .toString()
              .toLowerCase();

      return name.contains(query) ||
          category.contains(query);
    }).toList();
  }

  // ============================================================
  // LOAD PRODUCTS
  // ============================================================

  Future<void> _loadProducts() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final result =
          await _database.getWarehouseProducts();

      if (!mounted) {
        return;
      }

      setState(() {
        products =
            List<Map<String, dynamic>>.from(
          result,
        );

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      _showMessage(
        'Gagal memuat produk: $e',
      );
    }
  }

  // ============================================================
  // TRANSFER TO DISPLAY
  // ============================================================

  Future<void> _transferToDisplay(
    int menuId,
    int quantity,
  ) async {
    if (quantity <= 0) {
      return;
    }

    try {
      final success =
          await _database.transferStockToDisplay(
        menuId: menuId,
        quantity: quantity,
      );

      if (!success) {
        _showMessage(
          'Stok gudang tidak mencukupi.',
        );
        return;
      }

      await _loadProducts();

      if (!mounted) {
        return;
      }

      _showMessage(
        'Stok berhasil dipindahkan ke display.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Gagal memindahkan stok: $e',
      );
    }
  }

  // ============================================================
  // TRANSFER TO WAREHOUSE
  // ============================================================

  Future<void> _transferToWarehouse(
    int menuId,
    int quantity,
  ) async {
    if (quantity <= 0) {
      return;
    }

    try {
      final success =
          await _database.transferStockToWarehouse(
        menuId: menuId,
        quantity: quantity,
      );

      if (!success) {
        _showMessage(
          'Stok display tidak mencukupi.',
        );
        return;
      }

      await _loadProducts();

      if (!mounted) {
        return;
      }

      _showMessage(
        'Stok berhasil dikembalikan ke gudang.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Gagal mengembalikan stok: $e',
      );
    }
  }

  // ============================================================
  // ADD STOCK DIALOG
  // ============================================================

  Future<void> _showAddStockDialog(
    Map<String, dynamic> product,
  ) async {
    String input = '1';

    final quantity = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF1D1E20),

          scrollable: true,

          title: const Text(
            'Tambah Stok Gudang',
            style: TextStyle(
              color: Colors.white,
            ),
          ),

          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                product['name']
                        ?.toString() ??
                    '-',
                style:
                    const TextStyle(
                  color:
                      Colors.white70,
                  fontSize: 13,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              TextField(
                autofocus: true,

                keyboardType:
                    TextInputType.number,

                onChanged: (value) {
                  input = value;
                },

                style:
                    const TextStyle(
                  color:
                      Colors.white,
                ),

                decoration:
                    InputDecoration(
                  labelText:
                      'Jumlah',

                  labelStyle:
                      const TextStyle(
                    color:
                        Colors.white70,
                  ),

                  filled: true,

                  fillColor:
                      const Color(
                    0xFF2B2B2B,
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),

                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: const Text(
                'Batal',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                final value =
                    int.tryParse(
                  input.trim(),
                );

                if (value == null ||
                    value <= 0) {
                  return;
                }

                Navigator.of(
                  dialogContext,
                ).pop(value);
              },
              child: const Text(
                'Tambah',
              ),
            ),
          ],
        );
      },
    );

    if (!mounted ||
        quantity == null) {
      return;
    }

    final menuId =
        _toInt(product['menu_id']);

    try {
      await _database.addWarehouseStock(
        menuId: menuId,
        quantity: quantity,
      );

      if (!mounted) {
        return;
      }

      await _loadProducts();

      if (!mounted) {
        return;
      }

      _showMessage(
        'Stok gudang berhasil ditambah.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Gagal menambah stok: $e',
      );
    }
  }

  // ============================================================
  // TRANSFER DIALOG
  // ============================================================

  Future<void> _showTransferDialog({
    required Map<String, dynamic> product,
    required bool toDisplay,
  }) async {
    final available = toDisplay
        ? _toInt(
            product['warehouse_stock'],
          )
        : _toInt(
            product['display_stock'],
          );

    if (available <= 0) {
      _showMessage(
        toDisplay
            ? 'Tidak ada stok gudang untuk dipindahkan.'
            : 'Tidak ada stok display untuk dikembalikan.',
      );

      return;
    }

    String input = '1';

    final quantity = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF1D1E20),

          scrollable: true,

          title: Text(
            toDisplay
                ? 'Kirim ke Display'
                : 'Kembalikan ke Gudang',
            style:
                const TextStyle(
              color: Colors.white,
            ),
          ),

          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                product['name']
                        ?.toString() ??
                    '-',
                style:
                    const TextStyle(
                  color:
                      Colors.white70,
                  fontSize: 13,
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              Text(
                'Stok tersedia: $available',
                style:
                    const TextStyle(
                  color:
                      Colors.white54,
                  fontSize: 12,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              TextField(
                autofocus: true,

                keyboardType:
                    TextInputType.number,

                onChanged: (value) {
                  input = value;
                },

                style:
                    const TextStyle(
                  color:
                      Colors.white,
                ),

                decoration:
                    InputDecoration(
                  labelText:
                      'Jumlah',

                  labelStyle:
                      const TextStyle(
                    color:
                        Colors.white70,
                  ),

                  filled: true,

                  fillColor:
                      const Color(
                    0xFF2B2B2B,
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),

                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: const Text(
                'Batal',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                final value =
                    int.tryParse(
                  input.trim(),
                );

                if (value == null ||
                    value <= 0 ||
                    value > available) {
                  return;
                }

                Navigator.of(
                  dialogContext,
                ).pop(value);
              },
              child: Text(
                toDisplay
                    ? 'Kirim'
                    : 'Kembalikan',
              ),
            ),
          ],
        );
      },
    );

    if (!mounted ||
        quantity == null) {
      return;
    }

    final menuId =
        _toInt(product['menu_id']);

    if (toDisplay) {
      await _transferToDisplay(
        menuId,
        quantity,
      );
    } else {
      await _transferToWarehouse(
        menuId,
        quantity,
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text(message),
        ),
      );
  }

  // ============================================================
  // RUPIAH
  // ============================================================

  String _formatRupiah(int value) {
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

      if (count == 3 &&
          i != 0) {
        result =
            '.$result';

        count = 0;
      }
    }

    return result;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final items =
        filteredProducts;

    return Scaffold(
      backgroundColor:
          const Color(0xFF101112),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF101112),

        foregroundColor:
            Colors.white,

        elevation: 0,

        title: const Text(
          'Gudang',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed:
                _loadProducts,
            icon:
                const Icon(
              Icons.refresh,
            ),
            tooltip:
                'Refresh',
          ),
        ],
      ),

      body: SafeArea(
        top: false,

        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(
            14,
            8,
            14,
            14,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ==================================================
              // SUMMARY
              // ==================================================

              _buildSummary(),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // SEARCH
              // ==================================================

              _buildSearchBar(),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // TITLE
              // ==================================================

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Daftar Stok Produk',
                      style:
                          TextStyle(
                        color:
                            Colors.white,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  if (!isLoading)
                    Text(
                      '${items.length} produk',
                      style:
                          const TextStyle(
                        color:
                            Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              // ==================================================
              // PRODUCT AREA
              // ==================================================

              Expanded(
                child:
                    _buildProductArea(
                  items,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child:
              _buildSummaryCard(
            title:
                'Total Stock Gudang',
            value:
                totalWarehouseStock,
            icon:
                Icons.warehouse_outlined,
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child:
              _buildSummaryCard(
            title:
                'Total Stock Display',
            value:
                totalDisplayStock,
            icon:
                Icons.storefront_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required int value,
    required IconData icon,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(14),

      decoration:
          BoxDecoration(
        color:
            const Color(0xFF1A1B1D),

        borderRadius:
            BorderRadius.circular(
          14,
        ),

        border: Border.all(
          color:
              Colors.white10,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFF2B2B2B,
              ),

              borderRadius:
                  BorderRadius.circular(
                11,
              ),
            ),

            child: Icon(
              icon,
              color:
                  Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  maxLines: 1,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  '$value pcs',

                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 19,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar() {
    return Container(
      height: 48,

      decoration:
          BoxDecoration(
        color:
            const Color(0xFFE4E4E4),

        borderRadius:
            BorderRadius.circular(
          13,
        ),
      ),

      child: TextField(
        controller:
            _searchController,

        focusNode:
            _searchFocusNode,

        onChanged: (value) {
          setState(() {
            searchQuery =
                value;
          });
        },

        textInputAction:
            TextInputAction.search,

        keyboardType:
            TextInputType.text,

        style:
            const TextStyle(
          color:
              Colors.black,
          fontSize: 13,
        ),

        decoration:
            InputDecoration(
          prefixIcon:
              const Icon(
            Icons.search,
            color:
                Colors.black,
            size: 20,
          ),

          hintText:
              'Cari produk atau kategori...',

          hintStyle:
              const TextStyle(
            color:
                Colors.grey,
            fontSize: 13,
          ),

          suffixIcon:
              searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController
                            .clear();

                        setState(() {
                          searchQuery =
                              '';
                        });

                        _searchFocusNode
                            .requestFocus();
                      },

                      icon:
                          const Icon(
                        Icons.close,
                        color:
                            Colors.black54,
                        size: 19,
                      ),
                    )
                  : null,

          border:
              InputBorder.none,

          contentPadding:
              const EdgeInsets.symmetric(
            vertical: 13,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT AREA
  // ============================================================

  Widget _buildProductArea(
    List<Map<String, dynamic>>
        items,
  ) {
    if (isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(
          color:
              Colors.white,
        ),
      );
    }

    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior
              .onDrag,

      padding:
          const EdgeInsets.only(
        bottom: 20,
      ),

      itemCount:
          items.length,

      itemBuilder:
          (context, index) {
        return Padding(
          padding:
              const EdgeInsets.only(
            bottom: 10,
          ),

          child:
              _buildProductCard(
            items[index],
          ),
        );
      },
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    final isSearching =
        searchQuery
            .trim()
            .isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color:
                Colors.white38,
            size: 52,
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            isSearching
                ? 'Produk tidak ditemukan'
                : 'Belum ada produk',

            style:
                const TextStyle(
              color:
                  Colors.white,
              fontSize: 16,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            isSearching
                ? 'Coba gunakan nama produk atau kategori lain.'
                : 'Tambahkan produk terlebih dahulu melalui menu Menu.',

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              color:
                  Colors.white54,
              fontSize: 12,
            ),
          ),

          if (isSearching) ...[
            const SizedBox(
              height: 14,
            ),

            OutlinedButton(
              onPressed: () {
                _searchController
                    .clear();

                setState(() {
                  searchQuery =
                      '';
                });
              },

              child:
                  const Text(
                'Hapus pencarian',
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget _buildProductCard(
    Map<String, dynamic>
        product,
  ) {
    final menuId =
        _toInt(
      product['menu_id'],
    );

    final warehouse =
        _toInt(
      product['warehouse_stock'],
    );

    final display =
        _toInt(
      product['display_stock'],
    );

    final price =
        _toInt(
      product['price'],
    );

    final name =
        product['name']
                ?.toString() ??
            '-';

    final category =
        product['category_name']
                ?.toString() ??
            'Tanpa kategori';

    return Container(
      padding:
          const EdgeInsets.all(14),

      decoration:
          BoxDecoration(
        color:
            const Color(0xFF1A1B1D),

        borderRadius:
            BorderRadius.circular(
          14,
        ),

        border: Border.all(
          color:
              Colors.white10,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ======================================================
          // NAME
          // ======================================================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      name,

                      maxLines: 2,

                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      category,

                      style:
                          const TextStyle(
                        color:
                            Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Text(
                'Rp ${_formatRupiah(price)}',

                style:
                    const TextStyle(
                  color:
                      Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 14,
          ),

          // ======================================================
          // STOCK
          // ======================================================

          Row(
            children: [
              Expanded(
                child:
                    _buildStockBox(
                  label:
                      'Gudang',
                  value:
                      warehouse,
                  icon:
                      Icons.warehouse_outlined,
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                child:
                    _buildStockBox(
                  label:
                      'Display',
                  value:
                      display,
                  icon:
                      Icons.storefront_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          // ======================================================
          // ACTIONS
          // ======================================================

          Row(
            children: [
              Expanded(
                child:
                    OutlinedButton.icon(
                  onPressed:
                      () =>
                          _showAddStockDialog(
                    product,
                  ),

                  icon:
                      const Icon(
                    Icons.add,
                    size: 17,
                  ),

                  label:
                      const Text(
                    'Tambah Gudang',
                  ),

                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        Colors.white,

                    side:
                        const BorderSide(
                      color:
                          Colors.white24,
                    ),

                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 11,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              PopupMenuButton<String>(
                color:
                    const Color(
                  0xFF242527,
                ),

                onSelected:
                    (value) {
                  if (value ==
                      'display') {
                    _showTransferDialog(
                      product:
                          product,
                      toDisplay:
                          true,
                    );
                  }

                  if (value ==
                      'warehouse') {
                    _showTransferDialog(
                      product:
                          product,
                      toDisplay:
                          false,
                    );
                  }
                },

                itemBuilder:
                    (context) =>
                        const [
                  PopupMenuItem<String>(
                    value:
                        'display',

                    child:
                        Text(
                      'Kirim ke Display',

                      style:
                          TextStyle(
                        color:
                            Colors.white,
                      ),
                    ),
                  ),

                  PopupMenuItem<String>(
                    value:
                        'warehouse',

                    child:
                        Text(
                      'Kembalikan ke Gudang',

                      style:
                          TextStyle(
                        color:
                            Colors.white,
                      ),
                    ),
                  ),
                ],

                child:
                    Container(
                  width: 44,
                  height: 44,

                  alignment:
                      Alignment.center,

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFF2B2B2B,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),

                  child:
                      const Icon(
                    Icons.more_vert,
                    color:
                        Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STOCK BOX
  // ============================================================

  Widget _buildStockBox({
    required String label,
    required int value,
    required IconData icon,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 10,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(0xFF242527),

        borderRadius:
            BorderRadius.circular(
          10,
        ),
      ),

      child: Row(
        children: [
          Icon(
            icon,
            color:
                Colors.white70,
            size: 17,
          ),

          const SizedBox(
            width: 7,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  label,

                  style:
                      const TextStyle(
                    color:
                        Colors.white54,
                    fontSize: 10,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  '$value pcs',

                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}