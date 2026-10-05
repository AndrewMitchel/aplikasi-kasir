import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../models/menu_model.dart';
import '../services/menu_service.dart';

class MenuManagementPage extends StatefulWidget {
  const MenuManagementPage({
    super.key,
  });

  @override
  State<MenuManagementPage> createState() =>
      _MenuManagementPageState();
}

class _MenuManagementPageState
    extends State<MenuManagementPage> {
  List<CategoryModel> categories = [];
  List<MenuModel> menuItems = [];

  int? selectedCategoryId;

  bool isLoadingCategories = true;
  bool isLoadingMenu = false;

  @override
  void initState() {
    super.initState();

    _loadCategories();
  }

  // ============================================================
  // LOAD CATEGORIES
  // ============================================================

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
        await _loadMenu(
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

      _showMessage(
        'Gagal memuat kategori: $e',
      );
    }
  }

  // ============================================================
  // LOAD MENU
  // ============================================================

  Future<void> _loadMenu(
    int categoryId,
  ) async {
    if (!mounted) {
      return;
    }

    setState(() {
      selectedCategoryId = categoryId;
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

      _showMessage(
        'Gagal memuat menu: $e',
      );
    }
  }

  // ============================================================
  // ADD MENU
  // ============================================================

  Future<void> _showAddMenuDialog() async {
    if (selectedCategoryId == null) {
      _showMessage(
        'Pilih kategori terlebih dahulu.',
      );

      return;
    }

    final nameController =
        TextEditingController();

    final priceController =
        TextEditingController();

    final result =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return _MenuFormDialog(
          title: 'Tambah Produk',
          nameController:
              nameController,
          priceController:
              priceController,
          buttonText: 'Tambah',
        );
      },
    );

    nameController.dispose();
    priceController.dispose();

    if (result == true &&
        selectedCategoryId != null) {
      await _loadMenu(
        selectedCategoryId!,
      );
    }
  }

  // ============================================================
  // EDIT MENU
  // ============================================================

  Future<void> _showEditMenuDialog(
    MenuModel menu,
  ) async {
    final nameController =
        TextEditingController(
      text: menu.name,
    );

    final priceController =
        TextEditingController(
      text: menu.price.toString(),
    );

    final result =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return _MenuFormDialog(
          title: 'Edit Produk',
          nameController:
              nameController,
          priceController:
              priceController,
          buttonText: 'Simpan',
          menuId:
              menu.id,
          categoryId:
              menu.categoryId,
        );
      },
    );

    nameController.dispose();
    priceController.dispose();

    if (result == true &&
        selectedCategoryId != null) {
      await _loadMenu(
        selectedCategoryId!,
      );
    }
  }

  // ============================================================
  // DELETE MENU
  // ============================================================

  Future<void> _deleteMenu(
    MenuModel menu,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              const Color(
            0xFF1A1C1E,
          ),
          title:
              const Text(
            'Hapus Produk',
            style:
                TextStyle(
              color:
                  Colors.white,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          content:
              Text(
            'Yakin ingin menghapus "${menu.name}"?',
            style:
                const TextStyle(
              color:
                  Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
                  const Text(
                'Batal',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              child:
                  const Text(
                'Hapus',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await MenuService.deleteMenu(
        menu.id,
      );

      if (selectedCategoryId != null) {
        await _loadMenu(
          selectedCategoryId!,
        );
      }

      _showMessage(
        'Produk berhasil dihapus.',
      );
    } catch (e) {
      _showMessage(
        'Gagal menghapus produk: $e',
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
            Text(
          message,
        ),
      ),
    );
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
      int i =
          number.length - 1;
      i >= 0;
      i--
    ) {
      result =
          number[i] +
              result;

      count++;

      if (count == 3 &&
          i != 0) {
        result =
            '.$result';

        count = 0;
      }
    }

    return 'Rp $result';
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
  // CATEGORY CARD
  // ============================================================

  Widget _buildCategoryCard(
    CategoryModel category, {
    required bool horizontal,
  }) {
    final isSelected =
        selectedCategoryId ==
            category.id;

    return InkWell(
      borderRadius:
          BorderRadius.circular(
        12,
      ),
      onTap: () {
        _loadMenu(
          category.id,
        );
      },
      child: Container(
        width:
            horizontal
                ? 150
                : null,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        decoration:
            BoxDecoration(
          color: isSelected
              ? Color(
                  category.colorValue,
                )
              : const Color(
                  0xFF202326,
                ),
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          border: isSelected
              ? Border.all(
                  color:
                      Colors.white,
                  width:
                      1.5,
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              _getCategoryIcon(
                category.iconName,
              ),
              color:
                  Colors.white,
              size:
                  20,
            ),

            const SizedBox(
              width:
                  8,
            ),

            Expanded(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    category.name,
                    maxLines:
                        1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        TextStyle(
                      color:
                          Colors.white,
                      fontSize:
                          13,
                      fontWeight:
                          isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),

                  const SizedBox(
                    height:
                        2,
                  ),

                  Text(
                    '${category.itemCount} items',
                    maxLines:
                        1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      color:
                          Colors.white70,
                      fontSize:
                          9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget _buildProductCard(
    MenuModel menu, {
    required bool compact,
  }) {
    return Container(
      padding:
          EdgeInsets.all(
        compact ? 13 : 16,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFF191B1D,
        ),
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border:
            Border.all(
          color:
              Colors.white.withValues(
            alpha:
                0.06,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ======================================================
          // NAMA PRODUK
          // ======================================================

          const Text(
            'Nama Produk',
            style:
                TextStyle(
              color:
                  Colors.white54,
              fontSize:
                  10,
            ),
          ),

          const SizedBox(
            height:
                4,
          ),

          Text(
            menu.name,
            maxLines:
                2,
            overflow:
                TextOverflow.ellipsis,
            style:
                TextStyle(
              color:
                  Colors.white,
              fontSize:
                  compact ? 15 : 17,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height:
                10,
          ),

          // ======================================================
          // HARGA
          // ======================================================

          const Text(
            'Harga',
            style:
                TextStyle(
              color:
                  Colors.white54,
              fontSize:
                  10,
            ),
          ),

          const SizedBox(
            height:
                3,
          ),

          Text(
            _formatRupiah(
              menu.price,
            ),
            maxLines:
                1,
            overflow:
                TextOverflow.ellipsis,
            style:
                TextStyle(
              color:
                  Colors.white,
              fontSize:
                  compact ? 14 : 16,
              fontWeight:
                  FontWeight.w500,
            ),
          ),

          const Spacer(),

          // ======================================================
          // BUTTON
          // ======================================================

          Row(
            children: [
              Expanded(
                child:
                    SizedBox(
                  height:
                      compact ? 34 : 38,
                  child:
                      OutlinedButton.icon(
                    onPressed: () {
                      _showEditMenuDialog(
                        menu,
                      );
                    },
                    icon:
                        Icon(
                      Icons.edit_outlined,
                      size:
                          compact ? 15 : 17,
                    ),
                    label:
                        const Text(
                      'Edit',
                    ),
                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          Colors.white,
                      side:
                          BorderSide(
                        color:
                            Colors.white.withValues(
                          alpha:
                              0.15,
                        ),
                      ),
                      padding:
                          EdgeInsets.zero,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width:
                    6,
              ),

              SizedBox(
                width:
                    compact ? 36 : 40,
                height:
                    compact ? 34 : 38,
                child:
                    IconButton(
                  padding:
                      EdgeInsets.zero,
                  onPressed: () {
                    _deleteMenu(
                      menu,
                    );
                  },
                  icon:
                      const Icon(
                    Icons.delete_outline,
                    color:
                        Colors.redAccent,
                    size:
                        20,
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
  // MOBILE PRODUCT LIST
  // ============================================================

  Widget _buildMobileProductList(
    BoxConstraints constraints,
  ) {
    final compact =
        constraints.maxWidth <
            380;

    if (menuItems.isEmpty) {
      return const Center(
        child:
            Text(
          'Belum ada produk di kategori ini.',
          textAlign:
              TextAlign.center,
          style:
              TextStyle(
            color:
                Colors.white54,
          ),
        ),
      );
    }

    return ListView.separated(
      padding:
          const EdgeInsets.only(
        bottom:
            20,
      ),
      itemCount:
          menuItems.length,
      separatorBuilder:
          (_, _) =>
              const SizedBox(
        height:
            10,
      ),
      itemBuilder:
          (
        context,
        index,
      ) {
        return SizedBox(
          height:
              compact ? 150 : 164,
          child:
              _buildProductCard(
            menuItems[index],
            compact:
                true,
          ),
        );
      },
    );
  }

  // ============================================================
  // TABLET / DESKTOP PRODUCT GRID
  // ============================================================

  Widget _buildWideProductGrid(
    BoxConstraints constraints,
  ) {
    if (menuItems.isEmpty) {
      return const Center(
        child:
            Text(
          'Belum ada produk di kategori ini.',
          style:
              TextStyle(
            color:
                Colors.white54,
          ),
        ),
      );
    }

    final width =
        constraints.maxWidth;

    int columns;

    if (width >= 1200) {
      columns = 4;
    } else if (width >= 850) {
      columns = 3;
    } else {
      columns = 2;
    }

    final compact =
        width < 900;

    final cardHeight =
        compact ? 185.0 : 200.0;

    return GridView.builder(
      padding:
          const EdgeInsets.only(
        bottom:
            20,
      ),
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            columns,
        crossAxisSpacing:
            14,
        mainAxisSpacing:
            14,
        mainAxisExtent:
            cardHeight,
      ),
      itemCount:
          menuItems.length,
      itemBuilder:
          (
        context,
        index,
      ) {
        return _buildProductCard(
          menuItems[index],
          compact:
              compact,
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(
        0xFF101112,
      ),
      appBar:
          AppBar(
        backgroundColor:
            const Color(
          0xFF101112,
        ),
        elevation:
            0,
        title:
            const Text(
          'Menu',
          style:
              TextStyle(
            color:
                Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        iconTheme:
            const IconThemeData(
          color:
              Colors.white,
        ),
      ),
      body:
          isLoadingCategories
              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )
              : categories.isEmpty
                  ? const Center(
                      child:
                          Text(
                        'Belum ada kategori.',
                        style:
                            TextStyle(
                          color:
                              Colors.white70,
                        ),
                      ),
                    )
                  : LayoutBuilder(
                      builder:
                          (
                        context,
                        constraints,
                      ) {
                        final isMobile =
                            constraints.maxWidth <
                                700;

                        // ==================================================
                        // MOBILE
                        // ==================================================

                        if (isMobile) {
                          return Column(
                            children: [
                              // ==========================================
                              // MOBILE CATEGORY
                              // ==========================================

                              Container(
                                height:
                                    92,
                                width:
                                    double.infinity,
                                padding:
                                    const EdgeInsets
                                        .fromLTRB(
                                  14,
                                  10,
                                  0,
                                  10,
                                ),
                                color:
                                    const Color(
                                  0xFF17191B,
                                ),
                                child:
                                    Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Kategori',
                                      style:
                                          TextStyle(
                                        color:
                                            Colors.white,
                                        fontSize:
                                            13,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(
                                      height:
                                          8,
                                    ),

                                    Expanded(
                                      child:
                                          ListView.separated(
                                        scrollDirection:
                                            Axis.horizontal,
                                        padding:
                                            const EdgeInsets
                                                .only(
                                          right:
                                              14,
                                        ),
                                        itemCount:
                                            categories.length,
                                        separatorBuilder:
                                            (
                                          _,
                                          _,
                                        ) =>
                                                const SizedBox(
                                          width:
                                              8,
                                        ),
                                        itemBuilder:
                                            (
                                          context,
                                          index,
                                        ) {
                                          return _buildCategoryCard(
                                            categories[index],
                                            horizontal:
                                                true,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ==========================================
                              // MOBILE CONTENT
                              // ==========================================

                              Expanded(
                                child:
                                    Padding(
                                  padding:
                                      const EdgeInsets.all(
                                    14,
                                  ),
                                  child:
                                      Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Expanded(
                                            child:
                                                Text(
                                              'Daftar Produk',
                                              style:
                                                  TextStyle(
                                                color:
                                                    Colors.white,
                                                fontSize:
                                                    20,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                          ),

                                          SizedBox(
                                            height:
                                                38,
                                            child:
                                                ElevatedButton.icon(
                                              onPressed:
                                                  _showAddMenuDialog,
                                              icon:
                                                  const Icon(
                                                Icons.add,
                                                size:
                                                    18,
                                              ),
                                              label:
                                                  const Text(
                                                'Tambah',
                                              ),
                                              style:
                                                  ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(
                                                  0xFF2C7BE5,
                                                ),
                                                foregroundColor:
                                                    Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal:
                                                      12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                        height:
                                            14,
                                      ),

                                      Expanded(
                                        child:
                                            isLoadingMenu
                                                ? const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  )
                                                : _buildMobileProductList(
                                                    constraints,
                                                  ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        // ==================================================
                        // TABLET / DESKTOP
                        // ==================================================

                        final categoryWidth =
                            constraints.maxWidth >=
                                    1100
                                ? 220.0
                                : 190.0;

                        return Row(
                          children: [
                            // ==============================================
                            // CATEGORY SIDEBAR
                            // ==============================================

                            Container(
                              width:
                                  categoryWidth,
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFF17191B,
                                ),
                                border:
                                    Border(
                                  right:
                                      BorderSide(
                                    color:
                                        Colors.white.withValues(
                                      alpha:
                                          0.06,
                                    ),
                                  ),
                                ),
                              ),
                              child:
                                  Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(
                                      14,
                                      16,
                                      14,
                                      12,
                                    ),
                                    child:
                                        Text(
                                      'Kategori',
                                      style:
                                          TextStyle(
                                        color:
                                            Colors.white,
                                        fontSize:
                                            16,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child:
                                        ListView.separated(
                                      padding:
                                          const EdgeInsets.fromLTRB(
                                        14,
                                        0,
                                        14,
                                        16,
                                      ),
                                      itemCount:
                                          categories.length,
                                      separatorBuilder:
                                          (
                                        _,
                                        _,
                                      ) =>
                                              const SizedBox(
                                        height:
                                            8,
                                      ),
                                      itemBuilder:
                                          (
                                        context,
                                        index,
                                      ) {
                                        return SizedBox(
                                          height:
                                              58,
                                          child:
                                              _buildCategoryCard(
                                            categories[index],
                                            horizontal:
                                                false,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ==============================================
                            // PRODUCT AREA
                            // ==============================================

                            Expanded(
                              child:
                                  Padding(
                                padding:
                                    const EdgeInsets.all(
                                  20,
                                ),
                                child:
                                    Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Expanded(
                                          child:
                                              Text(
                                            'Daftar Produk',
                                            style:
                                                TextStyle(
                                              color:
                                                  Colors.white,
                                              fontSize:
                                                  22,
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        ElevatedButton.icon(
                                          onPressed:
                                              _showAddMenuDialog,
                                          icon:
                                              const Icon(
                                            Icons.add,
                                          ),
                                          label:
                                              const Text(
                                            'Tambah Produk',
                                          ),
                                          style:
                                              ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(
                                              0xFF2C7BE5,
                                            ),
                                            foregroundColor:
                                                Colors.white,
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal:
                                                  16,
                                              vertical:
                                                  13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                      height:
                                          20,
                                    ),

                                    Expanded(
                                      child:
                                          isLoadingMenu
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                )
                                              : _buildWideProductGrid(
                                                  constraints,
                                                ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
    );
  }
}

// ============================================================
// MENU FORM DIALOG
// ============================================================

class _MenuFormDialog
    extends StatefulWidget {
  final String title;

  final TextEditingController
      nameController;

  final TextEditingController
      priceController;

  final String buttonText;

  final int? menuId;
  final int? categoryId;

  const _MenuFormDialog({
    required this.title,
    required this.nameController,
    required this.priceController,
    required this.buttonText,
    this.menuId,
    this.categoryId,
  });

  @override
  State<_MenuFormDialog> createState() =>
      _MenuFormDialogState();
}

class _MenuFormDialogState
    extends State<_MenuFormDialog> {
  bool isSaving = false;

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _save() async {
    final name =
        widget.nameController.text.trim();

    final priceText =
        widget.priceController.text
            .replaceAll(
              '.',
              '',
            )
            .trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text(
            'Nama produk harus diisi.',
          ),
        ),
      );

      return;
    }

    if (priceText.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text(
            'Harga produk harus diisi.',
          ),
        ),
      );

      return;
    }

    final price =
        int.tryParse(
      priceText,
    );

    if (price == null ||
        price < 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text(
            'Harga produk tidak valid.',
          ),
        ),
      );

      return;
    }

    if (widget.menuId == null &&
        widget.categoryId == null) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      if (widget.menuId == null) {
        await MenuService.addMenu(
          name:
              name,
          price:
              price,
          categoryId:
              widget.categoryId!,
        );
      } else {
        await MenuService.updateMenu(
          id:
              widget.menuId!,
          name:
              name,
          price:
              price,
          categoryId:
              widget.categoryId!,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text(
            'Gagal menyimpan produk: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // FORMAT PRICE
  // ============================================================

  void _formatPrice() {
    final digits =
        widget.priceController.text
            .replaceAll(
              '.',
              '',
            )
            .replaceAll(
              RegExp(
                r'[^0-9]',
              ),
              '',
            );

    if (digits.isEmpty) {
      return;
    }

    String formatted = '';
    int count = 0;

    for (
      int i =
          digits.length - 1;
      i >= 0;
      i--
    ) {
      formatted =
          digits[i] +
              formatted;

      count++;

      if (count == 3 &&
          i != 0) {
        formatted =
            '.$formatted';

        count = 0;
      }
    }

    widget.priceController.value =
        TextEditingValue(
      text:
          formatted,
      selection:
          TextSelection.collapsed(
        offset:
            formatted.length,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return AlertDialog(
      backgroundColor:
          const Color(
        0xFF1A1C1E,
      ),
      title:
          Text(
        widget.title,
        style:
            const TextStyle(
          color:
              Colors.white,
          fontWeight:
              FontWeight.bold,
        ),
      ),
      content:
          SingleChildScrollView(
        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            TextField(
              controller:
                  widget.nameController,
              style:
                  const TextStyle(
                color:
                    Colors.white,
              ),
              decoration:
                  InputDecoration(
                labelText:
                    'Nama Produk',
                labelStyle:
                    const TextStyle(
                  color:
                      Colors.white54,
                ),
                enabledBorder:
                    OutlineInputBorder(
                  borderSide:
                      BorderSide(
                    color:
                        Colors.white.withValues(
                      alpha:
                          0.12,
                    ),
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                focusedBorder:
                    const OutlineInputBorder(
                  borderSide:
                      BorderSide(
                    color:
                        Color(
                      0xFF2C7BE5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height:
                  14,
            ),

            TextField(
              controller:
                  widget.priceController,
              keyboardType:
                  TextInputType.number,
              onChanged: (_) {
                _formatPrice();
              },
              style:
                  const TextStyle(
                color:
                    Colors.white,
              ),
              decoration:
                  InputDecoration(
                labelText:
                    'Harga',
                prefixText:
                    'Rp ',
                prefixStyle:
                    const TextStyle(
                  color:
                      Colors.white70,
                ),
                labelStyle:
                    const TextStyle(
                  color:
                      Colors.white54,
                ),
                enabledBorder:
                    OutlineInputBorder(
                  borderSide:
                      BorderSide(
                    color:
                        Colors.white.withValues(
                      alpha:
                          0.12,
                    ),
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                focusedBorder:
                    const OutlineInputBorder(
                  borderSide:
                      BorderSide(
                    color:
                        Color(
                      0xFF2C7BE5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions:
          [
        TextButton(
          onPressed:
              isSaving
                  ? null
                  : () {
                      Navigator.pop(
                        context,
                        false,
                      );
                    },
          child:
              const Text(
            'Batal',
          ),
        ),
        ElevatedButton(
          onPressed:
              isSaving
                  ? null
                  : _save,
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                const Color(
              0xFF2C7BE5,
            ),
            foregroundColor:
                Colors.white,
          ),
          child:
              isSaving
                  ? const SizedBox(
                      width:
                          18,
                      height:
                          18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth:
                            2,
                        color:
                            Colors.white,
                      ),
                    )
                  : Text(
                      widget.buttonText,
                    ),
        ),
      ],
    );
  }
}