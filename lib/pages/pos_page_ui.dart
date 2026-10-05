part of 'pos_page.dart';

extension _PosPageUi on _PosPageState {
  // ============================================================
  // TABLET
  // ============================================================

  Widget _buildTabletLayout() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _buildTabletSidebar(),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      10,
                      18,
                      0,
                    ),
                    child: Column(
                      children: [
                        _buildSearchBar(),

                        const SizedBox(height: 16),

                        _buildTabletCategories(),

                        const SizedBox(height: 16),

                        Expanded(
                          child: _buildMenuGrid(
                            mobile: false,
                            tablet: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ORDER PANEL TABLET
                Container(
                  width: 310,
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 10,
                    bottom: 20,
                  ),
                  color: const Color(0xFF101112),
                  child: _buildOrderContent(),
                ),
              ],
            ),
          ),

          _buildTabletCartBar(),
        ],
      ),
    );
  }

  Widget _buildTabletSidebar() {
    return Container(
      width: 72,
      color: const Color(0xFF101112),
      child: Column(
        children: [
          const SizedBox(height: 14),

          const Icon(
            Icons.point_of_sale,
            color: Colors.white,
            size: 28,
          ),

          const SizedBox(height: 24),

          _tabletSidebarItem(
            Icons.menu,
            onTap: _openMenuManagement,
          ),

          _tabletSidebarItem(
            Icons.account_balance_outlined,
            onTap: _openAccounting,
          ),

          _tabletSidebarItem(
            Icons.receipt_long_outlined,
            onTap: _openTransactions,
          ),

          _tabletSidebarItem(
            Icons.inventory_2_outlined,
            onTap: _openWarehouse,
          ),

          _tabletSidebarItem(
            Icons.settings_outlined,
            onTap: _openSettings,
          ),
        ],
      ),
    );
  }

  Widget _tabletSidebarItem(
    IconData icon, {
    bool active = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 9,
      ),
      child: _SmoothTap(
        onTap: onTap,
        scale: 0.88,
        child: Container(
          width: 48,
          height: 40,
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF5A5B5D)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 21,
          ),
        ),
      ),
    );
  }

  Widget _buildTabletCategories() {
    if (isLoadingCategories) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          right: 20,
        ),
        itemCount: categories.length,
        separatorBuilder: (
          context,
          index,
        ) {
          return const SizedBox(width: 12);
        },
        itemBuilder: (
          context,
          index,
        ) {
          return SizedBox(
            width: 190,
            child: _buildCategoryCard(
              categories[index],
              mobile: false,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _buildDesktopLayout() {
    return SafeArea(
      child: Row(
        children: [
          _buildDesktopSidebar(),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                10,
                18,
                0,
              ),
              child: Column(
                children: [
                  _buildSearchBar(),

                  const SizedBox(height: 18),

                  Expanded(
                    child: Column(
                      children: [
                        _buildDesktopCategories(),

                        const SizedBox(height: 18),

                        Expanded(
                          child: _buildMenuGrid(
                            mobile: false,
                            tablet: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          _buildDesktopOrderPanel(),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    return Container(
      width: 125,
      color: const Color(0xFF101112),
      child: Column(
        children: [
          const SizedBox(height: 8),

          const Text(
            'Kotak Kasir',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          _sidebarItem(
            icon: Icons.menu,
            title: 'Menu',
            onTap: _openMenuManagement,
          ),

          _sidebarItem(
            icon: Icons.account_balance_outlined,
            title: 'Accounting',
            onTap: _openAccounting,
          ),

          _sidebarItem(
            icon: Icons.receipt_long_outlined,
            title: 'Transaksi',
            onTap: _openTransactions,
          ),

          _sidebarItem(
            icon: Icons.inventory_2_outlined,
            title: 'Gudang',
            onTap: _openWarehouse,
          ),

          const Spacer(),

          const Text(
            '©2022 Flutter POS',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),

          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _sidebarItem({
    required IconData icon,
    required String title,
    bool active = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: _SmoothTap(
        onTap: onTap,
        scale: 0.94,
        child: Column(
          children: [
            Container(
              width: 55,
              height: 32,
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF5A5B5D)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 21,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchBar() {
    return Row(
      children: [
        Container(
          width: 250,
          height: 31,
          decoration: BoxDecoration(
            color: const Color(0xFFE4E4E4),
            borderRadius: BorderRadius.circular(18),
          ),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black,
            ),
            decoration: const InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                size: 19,
                color: Colors.black,
              ),
              hintText: 'Search',
              hintStyle: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(
                bottom: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DESKTOP CATEGORIES
  // ============================================================

  Widget _buildDesktopCategories() {
    if (isLoadingCategories) {
      return const SizedBox(
        height: 375,
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return SizedBox(
      height: 375,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.45,
        ),
        itemCount: categories.length,
        itemBuilder: (
          context,
          index,
        ) {
          return _buildCategoryCard(
            categories[index],
            mobile: false,
          );
        },
      ),
    );
  }

  // ============================================================
  // CATEGORY CARD
  // ============================================================

  Widget _buildCategoryCard(
    CategoryModel category, {
    required bool mobile,
  }) {
    final selected =
        selectedCategoryId == category.id;

    return _SmoothTap(
      onTap: () {
        _selectCategory(
          category.id,
        );
      },
      scale: 0.96,
      child: Container(
        padding: EdgeInsets.all(
          mobile ? 12 : 14,
        ),
        decoration: BoxDecoration(
          color: Color(
            category.colorValue,
          ),
          borderRadius: BorderRadius.circular(15),
          border: selected
              ? Border.all(
                  color: Colors.white,
                  width: 2,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              _getCategoryIcon(
                category.iconName,
              ),
              color: const Color(0xFF202124),
              size: mobile ? 20 : 21,
            ),

            const Spacer(),

            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF202124),
                fontSize: mobile ? 18 : 24,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              '${category.itemCount} items',
              style: TextStyle(
                color: const Color(0xFF303030),
                fontSize: mobile ? 10 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MENU GRID
  // ============================================================

  Widget _buildMenuGrid({
    required bool mobile,
    required bool tablet,
    bool landscape = false,
  }) {
    if (isLoadingMenu) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    final items = filteredMenuItems;

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada menu',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: mobile
            ? landscape
                ? 3
                : 2
            : tablet
                ? 3
                : 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: mobile
            ? landscape
                ? 1.15
                : 0.95
            : tablet
                ? 1.20
                : 1.45,
      ),
      itemCount: items.length,
      itemBuilder: (
        context,
        index,
      ) {
        return _buildMenuCard(
          items[index],
          mobile: mobile,
        );
      },
    );
  }

  // ============================================================
  // MENU CARD
  // ============================================================

  Widget _buildMenuCard(
    MenuModel item, {
    required bool mobile,
  }) {
    final quantity = _getCartQuantity(
      item,
    );

    return _SmoothTap(
      onTap: () {
        _addMenuToCart(
          item,
        );
      },
      scale: 0.96,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2B2B),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Orders -> Kitchen',
              style: TextStyle(
                color: Colors.white,
                fontSize: mobile ? 9 : 12,
              ),
            ),

            SizedBox(
              height: mobile ? 8 : 12,
            ),

            Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: mobile ? 15 : 19,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Rp ${_formatRupiah(item.price)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: mobile ? 11 : 12,
              ),
            ),

            const Spacer(),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: [
                _smallButton(
                  Icons.remove,
                  () {
                    _removeMenuFromCart(
                      item,
                    );
                  },
                  mobile: mobile,
                ),

                SizedBox(
                  width: mobile ? 6 : 9,
                ),

                Text(
                  '$quantity',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: mobile ? 12 : 14,
                  ),
                ),

                SizedBox(
                  width: mobile ? 6 : 9,
                ),

                _smallButton(
                  Icons.add,
                  () {
                    _addMenuToCart(
                      item,
                    );
                  },
                  mobile: mobile,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SMALL BUTTON
  // ============================================================

  Widget _smallButton(
    IconData icon,
    VoidCallback onTap, {
    required bool mobile,
  }) {
    final size = mobile ? 27.0 : 30.0;

    return _SmoothTap(
      onTap: onTap,
      scale: 0.82,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: mobile ? 14 : 16,
        ),
      ),
    );
  }

  // ============================================================
  // DESKTOP ORDER PANEL
  // ============================================================

  Widget _buildDesktopOrderPanel() {
    return Container(
      width: 310,
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: 20,
      ),
      color: const Color(0xFF101112),
      child: _buildOrderContent(),
    );
  }

  Widget _buildOrderContent() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Order',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        Expanded(
          child: cart.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada pesanan',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: cart.map(
                      (
                        item,
                      ) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 8,
                          ),
                          child:
                              _desktopCartRow(
                            item,
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
        ),

        const SizedBox(height: 10),

        _buildDesktopPaymentSummary(),
      ],
    );
  }

  // ============================================================
  // CART ROW
  // ============================================================

  Widget _desktopCartRow(
    CartItem item,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Rp ${_formatRupiah(item.price * item.quantity)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // MINUS
          _SmoothTap(
            onTap: () {
              _decreaseCartItem(
                item,
              );
            },
            scale: 0.82,
            child: Container(
              width: 27,
              height: 27,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                ),
                borderRadius:
                    BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.remove,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // QUANTITY
          SizedBox(
            width: 20,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // PLUS
          _SmoothTap(
            onTap: () {
              _increaseCartItem(
                item,
              );
            },
            scale: 0.82,
            child: Container(
              width: 27,
              height: 27,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                ),
                borderRadius:
                    BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DESKTOP PAYMENT SUMMARY
  // ============================================================

  Widget _buildDesktopPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // SUBTOTAL
          _summaryRow(
            'Subtotal',
            'Rp ${_formatRupiah(subtotal.toInt())}',
          ),

          // DISCOUNT
          if (discountPercentage > 0) ...[
            const SizedBox(height: 12),

            _summaryRow(
              'Discount ${_formatPercentage(discountPercentage)}%',
              '-Rp ${_formatRupiah(discountAmount.toInt())}',
            ),
          ],

          // TAX
          if (taxPercentage > 0) ...[
            const SizedBox(height: 12),

            _summaryRow(
              'Tax ${_formatPercentage(taxPercentage)}%',
              'Rp ${_formatRupiah(taxAmount.toInt())}',
            ),
          ],

          const SizedBox(height: 10),

          const Divider(
            color: Colors.white54,
            height: 1,
          ),

          const SizedBox(height: 10),

          // TOTAL
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              Text(
                'Rp ${_formatRupiah(total.toInt())}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // PAYMENT METHOD
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Payment Method',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              _paymentMethod(
                Icons.attach_money,
                'Cash',
              ),

              _paymentMethod(
                Icons.credit_card,
                'Debit Card',
              ),

              _paymentMethod(
                Icons.qr_code,
                'E-Wallet',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // PLACE ORDER
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: cart.isEmpty
                  ? null
                  : _openPaymentPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                disabledBackgroundColor:
                    Colors.white24,
                disabledForegroundColor:
                    Colors.white38,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'Place Order',
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLET CART BAR
  // ============================================================

  Widget _buildTabletCartBar() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF2B2B2B),
        border: Border(
          top: BorderSide(
            color: Colors.white24,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            color: Colors.white,
          ),

          const SizedBox(width: 10),

          Text(
            '$totalCartItems items',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),

          const Spacer(),

          Text(
            'Rp ${_formatRupiah(total.toInt())}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(width: 14),

          _SmoothTap(
            onTap: _showOrderBottomSheet,
            scale: 0.94,
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                disabledBackgroundColor:
                    Colors.white,
                foregroundColor: Colors.black,
                disabledForegroundColor:
                    Colors.black,
                elevation: 0,
              ),
              child: const Text(
                'View Order',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SHARED SUMMARY
  // ============================================================

  Widget _summaryRow(
    String title,
    String value,
  ) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),

        const Spacer(),

        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PAYMENT METHOD
  // ============================================================

  Widget _paymentMethod(
    IconData icon,
    String title,
  ) {
    final selected =
        selectedPaymentMethod == title;

    return _SmoothTap(
      onTap: () {
        setState(() {
          selectedPaymentMethod = title;
        });
      },
      scale: 0.90,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(
              milliseconds: 180,
            ),
            curve: Curves.easeOutCubic,
            width: selected ? 53 : 49,
            height: selected ? 43 : 40,
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white
                  : Colors.transparent,
              border: Border.all(
                color: Colors.white,
              ),
              borderRadius:
                  BorderRadius.circular(9),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Colors.white
                            .withValues(
                          alpha: 0.18,
                        ),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: selected
                  ? Colors.black
                  : Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: selected
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SMOOTH PRESS ANIMATION
// ============================================================

class _SmoothTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  const _SmoothTap({
    required this.child,
    this.onTap,
    this.scale = 0.96,
  });

  @override
  State<_SmoothTap> createState() =>
      _SmoothTapState();
}

class _SmoothTapState
    extends State<_SmoothTap> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted) return;

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onTapDown: (_) {
        _setPressed(true);
      },

      onTapUp: (_) {
        _setPressed(false);

        Future.delayed(
          const Duration(
            milliseconds: 30,
          ),
          () {
            if (mounted) {
              widget.onTap?.call();
            }
          },
        );
      },

      onTapCancel: () {
        _setPressed(false);
      },

      child: AnimatedScale(
        scale: _pressed
            ? widget.scale
            : 1.0,
        duration: const Duration(
          milliseconds: 130,
        ),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}