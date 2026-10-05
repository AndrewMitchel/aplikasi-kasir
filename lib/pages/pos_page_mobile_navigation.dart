part of 'pos_page.dart';

extension _PosPageMobileNavigation on _PosPageState {
  // ============================================================
  // MOBILE HEADER
  // ============================================================

  Widget _buildMobileHeader() {
    return Padding(
      padding:
          const EdgeInsets
              .fromLTRB(
        14,
        10,
        14,
        6,
      ),
      child:
          Row(
        children: [
          GestureDetector(
            onTap:
                _showMobileNavigation,
            child:
                Container(
              width:
                  42,
              height:
                  42,
              margin:
                  const EdgeInsets.only(
                right:
                    10,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFF2B2B2B,
                ),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child:
                  const Icon(
                Icons.menu,
                color:
                    Colors.white,
                size:
                    22,
              ),
            ),
          ),

          const Expanded(
            child:
                Text(
              'Kotak Kasir',
              style:
                  TextStyle(
                color:
                    Colors.white,
                fontSize:
                    21,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          // ======================================================
          // SETTINGS
          // ======================================================

          GestureDetector(
            onTap:
                _openSettings,
            child:
                Container(
              width:
                  42,
              height:
                  42,
              margin:
                  const EdgeInsets.only(
                right:
                    8,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFF2B2B2B,
                ),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child:
                  const Icon(
                Icons
                    .settings_outlined,
                color:
                    Colors.white,
                size:
                    21,
              ),
            ),
          ),

          // ======================================================
          // CART
          // ======================================================

          GestureDetector(
            onTap:
                _showOrderBottomSheet,
            child:
                Container(
              width:
                  42,
              height:
                  42,
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFF2B2B2B,
                ),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child:
                  Stack(
                alignment:
                    Alignment.center,
                children: [
                  const Icon(
                    Icons
                        .shopping_cart_outlined,
                    color:
                        Colors.white,
                    size:
                        22,
                  ),

                  if (totalCartItems >
                      0)
                    Positioned(
                      top:
                          3,
                      right:
                          4,
                      child:
                          Container(
                        width:
                            16,
                        height:
                            16,
                        alignment:
                            Alignment
                                .center,
                        decoration:
                            const BoxDecoration(
                          color:
                              Colors.red,
                          shape:
                              BoxShape
                                  .circle,
                        ),
                        child:
                            Text(
                          '$totalCartItems',
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize:
                                8,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE DRAWER
  // ============================================================

  void _showMobileNavigation() {
    showGeneralDialog(
      context:
          context,
      barrierDismissible:
          true,
      barrierLabel:
          'Mobile Navigation',
      barrierColor:
          Colors.black54,
      transitionDuration:
          const Duration(
        milliseconds:
            250,
      ),
      pageBuilder:
          (
        context,
        animation,
        secondaryAnimation,
      ) {
        final screenWidth =
            MediaQuery.of(
          context,
        ).size.width;

        final drawerWidth =
            screenWidth * 0.70 >
                    250
                ? 250.0
                : screenWidth *
                    0.70;

        return SafeArea(
          child:
              Align(
            alignment:
                Alignment
                    .centerLeft,
            child:
                Material(
              color:
                  Colors.transparent,
              child:
                  Container(
                width:
                    drawerWidth,
                height:
                    double.infinity,
                decoration:
                    const BoxDecoration(
                  color:
                      Color(
                    0xFF101112,
                  ),
                  borderRadius:
                      BorderRadius.only(
                    topRight:
                        Radius.circular(
                      18,
                    ),
                    bottomRight:
                        Radius.circular(
                      18,
                    ),
                  ),
                ),
                child:
                    Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets
                              .fromLTRB(
                        18,
                        16,
                        14,
                        10,
                      ),
                      child:
                          Row(
                        children: [
                          const Expanded(
                            child:
                                Text(
                              'Menu',
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

                          GestureDetector(
                            onTap: () {
                              Navigator.pop(
                                context,
                              );
                            },
                            child:
                                const Icon(
                              Icons.close,
                              color:
                                  Colors.white70,
                              size:
                                  22,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(
                      color:
                          Colors.white24,
                      height:
                          1,
                    ),

                    Expanded(
                      child:
                          SingleChildScrollView(
                        padding:
                            const EdgeInsets
                                .fromLTRB(
                          12,
                          12,
                          12,
                          18,
                        ),
                        child:
                            Column(
                          children: [
                            // ==================================================
                            // MENU
                            // ==================================================

                            _mobileNavigationItem(
                              icon:
                                  Icons.menu,
                              title:
                                  'Menu',
                              active:
                                  true,
                              onTap: () async {
                                Navigator.pop(
                                  context,
                                );

                                await _openMenuManagement();
                              },
                            ),

                            // ==================================================
                            // ACCOUNTING
                            // ==================================================

                            _mobileNavigationItem(
                              icon:
                                  Icons
                                      .account_balance_outlined,
                              title:
                                  'Accounting',
                              onTap: () {
                                Navigator.pop(
                                  context,
                                );

                                _openAccounting();
                              },
                            ),

                            // ==================================================
                            // TRANSAKSI
                            // ==================================================

                            _mobileNavigationItem(
                              icon:
                                  Icons
                                      .receipt_long_outlined,
                              title:
                                  'Transaksi',
                              onTap: () async {
                                Navigator.pop(
                                  context,
                                );

                                await _openTransactions();
                              },
                            ),

                            // ==================================================
                            // GUDANG
                            // ==================================================

                            _mobileNavigationItem(
                              icon:
                                  Icons
                                      .inventory_2_outlined,
                              title:
                                  'Gudang',
                              onTap: () async {
                                Navigator.pop(
                                  context,
                                );

                                await _openWarehouse();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder:
          (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        final curvedAnimation =
            CurvedAnimation(
          parent:
              animation,
          curve:
              Curves.easeOutCubic,
        );

        return SlideTransition(
          position:
              Tween<Offset>(
            begin:
                const Offset(
              -1,
              0,
            ),
            end:
                Offset.zero,
          ).animate(
            curvedAnimation,
          ),
          child:
              child,
        );
      },
    );
  }

  Widget _mobileNavigationItem({
    required IconData icon,
    required String title,
    bool active = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom:
            8,
      ),
      child:
          GestureDetector(
        onTap:
            onTap,
        child:
            Container(
          width:
              double.infinity,
          height:
              48,
          padding:
              const EdgeInsets
                  .symmetric(
            horizontal:
                14,
          ),
          decoration:
              BoxDecoration(
            color:
                active
                    ? const Color(
                        0xFF5A5B5D,
                      )
                    : const Color(
                        0xFF2B2B2B,
                      ),
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
          child:
              Row(
            children: [
              Icon(
                icon,
                color:
                    Colors.white,
                size:
                    21,
              ),

              const SizedBox(
                width:
                    12,
              ),

              Text(
                title,
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize:
                      13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MOBILE LANDSCAPE HEADER
  // ============================================================

  Widget _buildMobileLandscapeHeader() {
    return Padding(
      padding:
          const EdgeInsets
              .fromLTRB(
        14,
        6,
        14,
        2,
      ),
      child:
          Row(
        children: [
          GestureDetector(
            onTap:
                _showMobileNavigation,
            child:
                Container(
              width:
                  38,
              height:
                  38,
              margin:
                  const EdgeInsets
                      .only(
                right:
                    7,
              ),
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
              child:
                  const Icon(
                Icons.menu,
                color:
                    Colors.white,
                size:
                    20,
              ),
            ),
          ),

          const Expanded(
            child:
                Text(
              'Kotak Kasir',
              style:
                  TextStyle(
                color:
                    Colors.white,
                fontSize:
                    18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          // ======================================================
          // SETTINGS
          // ======================================================

          GestureDetector(
            onTap:
                _openSettings,
            child:
                Container(
              width:
                  38,
              height:
                  38,
              margin:
                  const EdgeInsets
                      .only(
                right:
                    7,
              ),
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
              child:
                  const Icon(
                Icons
                    .settings_outlined,
                color:
                    Colors.white,
                size:
                    20,
              ),
            ),
          ),

          // ======================================================
          // CART
          // ======================================================

          GestureDetector(
            onTap:
                _showOrderBottomSheet,
            child:
                Container(
              width:
                  38,
              height:
                  38,
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
              child:
                  Stack(
                alignment:
                    Alignment.center,
                children: [
                  const Icon(
                    Icons
                        .shopping_cart_outlined,
                    color:
                        Colors.white,
                    size:
                        20,
                  ),

                  if (totalCartItems >
                      0)
                    Positioned(
                      top:
                          2,
                      right:
                          3,
                      child:
                          Container(
                        width:
                            15,
                        height:
                            15,
                        alignment:
                            Alignment
                                .center,
                        decoration:
                            const BoxDecoration(
                          color:
                              Colors.red,
                          shape:
                              BoxShape
                                  .circle,
                        ),
                        child:
                            Text(
                          '$totalCartItems',
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize:
                                7,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}