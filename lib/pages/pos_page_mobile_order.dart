part of 'pos_page.dart';

extension _PosPageMobileOrder on _PosPageState {
  // ============================================================
  // MOBILE LANDSCAPE ORDER PANEL
  // ============================================================

  Widget _buildMobileLandscapeOrderPanel() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment
              .start,
      children: [
        Row(
          children: [
            const Expanded(
              child:
                  Text(
                'Current Order',
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

            Text(
              '$totalCartItems items',
              style:
                  const TextStyle(
                color:
                    Colors.white70,
                fontSize:
                    10,
              ),
            ),
          ],
        ),

        const SizedBox(
          height:
              4,
        ),

        const SizedBox(
          height:
              12,
        ),

        Expanded(
          child:
              cart.isEmpty
                  ? const Center(
                      child:
                          Text(
                        'Belum ada pesanan',
                        style:
                            TextStyle(
                          color:
                              Colors.white70,
                          fontSize:
                              12,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount:
                          cart.length,
                      separatorBuilder:
                          (
                        _,
                        _,
                      ) {
                        return const SizedBox(
                          height:
                              7,
                        );
                      },
                      itemBuilder:
                          (
                        context,
                        index,
                      ) {
                        return _landscapeCartRow(
                          cart[
                              index],
                        );
                      },
                    ),
        ),

        const SizedBox(
          height:
              10,
        ),

        _buildLandscapeOrderSummary(),
      ],
    );
  }

  Widget _landscapeCartRow(
    CartItem item,
  ) {
    return Container(
      padding:
          const EdgeInsets
              .symmetric(
        horizontal:
            9,
        vertical:
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
          9,
        ),
      ),
      child:
          Column(
        children: [
          Row(
            children: [
              Expanded(
                child:
                    Text(
                  item.name,
                  maxLines:
                      1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize:
                        11,
                    fontWeight:
                        FontWeight
                            .bold,
                  ),
                ),
              ),

              Text(
                'Rp ${_formatRupiah(item.price * item.quantity)}',
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize:
                      10,
                ),
              ),
            ],
          ),

          const SizedBox(
            height:
                5,
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .end,
            children: [
              GestureDetector(
                onTap:
                    () {
                  _decreaseCartItem(
                    item,
                  );
                },
                child:
                    const Icon(
                  Icons
                      .remove_circle_outline,
                  color:
                      Colors.white70,
                  size:
                      20,
                ),
              ),

              const SizedBox(
                width:
                    8,
              ),

              Text(
                '${item.quantity}',
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize:
                      11,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                width:
                    8,
              ),

              GestureDetector(
                onTap:
                    () {
                  _increaseCartItem(
                    item,
                  );
                },
                child:
                    const Icon(
                  Icons
                      .add_circle_outline,
                  color:
                      Colors.white,
                  size:
                      20,
                  ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LANDSCAPE ORDER SUMMARY
  // ============================================================

  Widget _buildLandscapeOrderSummary() {
    return Container(
      padding:
          const EdgeInsets
              .all(
        12,
      ),
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
          Column(
        children: [
          _summaryRow(
            'Subtotal',
            'Rp ${_formatRupiah(subtotal.toInt())}',
          ),

          if (discountPercentage >
              0) ...[
            const SizedBox(
              height:
                  7,
            ),
            _summaryRow(
              'Discount ${_formatPercentage(discountPercentage)}%',
              '-Rp ${_formatRupiah(discountAmount.toInt())}',
            ),
          ],

          const SizedBox(
            height:
                7,
          ),

          _summaryRow(
            'Tax ${_formatPercentage(taxPercentage)}%',
            'Rp ${_formatRupiah(taxAmount.toInt())}',
          ),

          const SizedBox(
            height:
                7,
          ),

          const Divider(
            color:
                Colors.white54,
            height:
                1,
          ),

          const SizedBox(
            height:
                7,
          ),

          Row(
            children: [
              const Text(
                'Total',
                style:
                    TextStyle(
                  color:
                      Colors.white,
                  fontSize:
                      17,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const Spacer(),

              Text(
                'Rp ${_formatRupiah(total.toInt())}',
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize:
                      17,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(
            height:
                12,
          ),

          Row(
            children: [
              Expanded(
                child:
                    _landscapePaymentButton(
                  Icons
                      .attach_money,
                  'Cash',
                ),
              ),

              const SizedBox(
                width:
                    6,
              ),

              Expanded(
                child:
                    _landscapePaymentButton(
                  Icons
                      .credit_card,
                  'Card',
                ),
              ),

              const SizedBox(
                width:
                    6,
              ),

              Expanded(
                child:
                    _landscapePaymentButton(
                  Icons.qr_code,
                  'QR',
                ),
              ),
            ],
          ),

          const SizedBox(
            height:
                10,
          ),

          SizedBox(
            width:
                double.infinity,
            height:
                34,
            child:
                ElevatedButton(
              onPressed:
                  cart.isEmpty
                      ? null
                      : _openPaymentPage,
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    Colors.white,
                foregroundColor:
                    Colors.black,
                disabledBackgroundColor:
                    Colors.white24,
                disabledForegroundColor:
                    Colors.white38,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
              ),
              child:
                  const Text(
                'Place Order',
                style:
                    TextStyle(
                  fontSize:
                      12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LANDSCAPE PAYMENT BUTTON
  // ============================================================

  Widget _landscapePaymentButton(
    IconData icon,
    String title,
  ) {
    final selected =
        selectedPaymentMethod ==
            title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod =
              title;
        });
      },
      child:
          Column(
        children: [
          Container(
            width:
                double.infinity,
            height:
                32,
            decoration:
                BoxDecoration(
              color:
                  selected
                      ? Colors.white
                      : Colors.transparent,
              border:
                  Border.all(
                color:
                    Colors.white,
              ),
              borderRadius:
                  BorderRadius.circular(
                8,
              ),
            ),
            child:
                Icon(
              icon,
              color:
                  selected
                      ? Colors.black
                      : Colors.white,
              size:
                  17,
            ),
          ),

          const SizedBox(
            height:
                3,
          ),

          Text(
            title,
            style:
                TextStyle(
              color:
                  Colors.white,
              fontSize:
                  8,
              fontWeight:
                  selected
                      ? FontWeight.bold
                      : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE CART BAR
  // ============================================================

  Widget _buildMobileCartBar() {
    return GestureDetector(
      onTap:
          _showOrderBottomSheet,
      child:
          Container(
        width:
            double.infinity,
        height:
            64,
        margin:
            const EdgeInsets
                .fromLTRB(
          12,
          6,
          12,
          10,
        ),
        padding:
            const EdgeInsets
                .symmetric(
          horizontal:
              14,
        ),
        decoration:
            BoxDecoration(
          color:
              const Color(
            0xFF2B2B2B,
          ),
          borderRadius:
              BorderRadius.circular(
            16,
          ),
        ),
        child: Row(
          children: [
            Container(
              width:
                  36,
              height:
                  36,
              alignment:
                  Alignment.center,
              decoration:
                  const BoxDecoration(
                color:
                    Colors.white,
                shape:
                    BoxShape.circle,
              ),
              child:
                  Text(
                '$totalCartItems',
                style:
                    const TextStyle(
                  color:
                      Colors.black,
                  fontSize:
                      12,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(
              width:
                  10,
            ),

            const Expanded(
              child:
                  Column(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'Current Order',
                    style:
                        TextStyle(
                      color:
                          Colors.white70,
                      fontSize:
                          9,
                    ),
                  ),

                  Text(
                    'View order',
                    style:
                        TextStyle(
                      color:
                          Colors.white,
                      fontSize:
                          12,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              'Rp ${_formatRupiah(total.toInt())}',
              style:
                  const TextStyle(
                color:
                    Colors.white,
                fontSize:
                    13,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              width:
                  7,
            ),

            const Icon(
              Icons
                  .arrow_forward_ios,
              color:
                  Colors.white,
              size:
                  13,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // VIEW ORDER
  // ============================================================

  void _showOrderBottomSheet() {
    showModalBottomSheet(
      context:
          context,
      isScrollControlled:
          true,
      backgroundColor:
          Colors.transparent,
      builder:
          (context) {
        return DraggableScrollableSheet(
          initialChildSize:
              0.82,
          minChildSize:
              0.55,
          maxChildSize:
              0.95,
          expand:
              false,
          builder:
              (
            context,
            scrollController,
          ) {
            return StatefulBuilder(
              builder:
                  (
                context,
                setModalState,
              ) {
                return Container(
                  decoration:
                      const BoxDecoration(
                    color:
                        Color(
                      0xFF101112,
                    ),
                    borderRadius:
                        BorderRadius
                            .vertical(
                      top:
                          Radius.circular(
                        24,
                      ),
                    ),
                  ),
                  child:
                      Column(
                    children: [
                      const SizedBox(
                        height:
                            10,
                      ),

                      Container(
                        width:
                            45,
                        height:
                            5,
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white38,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height:
                            15,
                      ),

                      Padding(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal:
                              20,
                        ),
                        child:
                            Row(
                          children: [
                            const Expanded(
                              child:
                                  Text(
                                'Current Order',
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

                            Text(
                              '$totalCartItems items',
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white70,
                                fontSize:
                                    12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height:
                            15,
                      ),

                      Expanded(
                        child:
                            ListView(
                          controller:
                              scrollController,
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal:
                                16,
                          ),
                          children: [
                            if (cart
                                .isEmpty)
                              const Padding(
                                padding:
                                    EdgeInsets
                                        .symmetric(
                                  vertical:
                                      50,
                                ),
                                child:
                                    Center(
                                  child:
                                      Text(
                                    'Belum ada pesanan',
                                    style:
                                        TextStyle(
                                      color:
                                          Colors.white70,
                                      fontSize:
                                          14,
                                    ),
                                  ),
                                ),
                              ),

                            ...cart.map(
                              (
                                item,
                              ) =>
                                  Padding(
                                padding:
                                    const EdgeInsets
                                        .only(
                                  bottom:
                                      8,
                                ),
                                child:
                                    _mobileCartRow(
                                  item,
                                  onChanged:
                                      () {
                                    setModalState(
                                      () {},
                                    );
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(
                              height:
                                  8,
                            ),

                            _buildMobilePaymentSummary(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ============================================================
  // MOBILE CART ROW
  // ============================================================

  Widget _mobileCartRow(
    CartItem item, {
    required VoidCallback
        onChanged,
  }) {
    return Container(
      padding:
          const EdgeInsets
              .all(
        12,
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
          Row(
        children: [
          Container(
            width:
                32,
            height:
                32,
            alignment:
                Alignment.center,
            decoration:
                const BoxDecoration(
              color:
                  Colors.white,
              shape:
                  BoxShape.circle,
            ),
            child:
                Text(
              '${item.quantity}',
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF287BD6,
                ),
                fontSize:
                    12,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(
            width:
                10,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  item.name,
                  maxLines:
                      1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
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
                      3,
                ),

                Text(
                  'Rp ${_formatRupiah(item.price)}',
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize:
                        11,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed:
                () {
              _decreaseCartItem(
                item,
              );

              onChanged();
            },
            icon:
                const Icon(
              Icons
                  .remove_circle_outline,
              color:
                  Colors.white70,
              size:
                  23,
            ),
          ),

          Text(
            '${item.quantity}',
            style:
                const TextStyle(
              color:
                  Colors.white,
              fontSize:
                  13,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          IconButton(
            onPressed:
                () {
              _increaseCartItem(
                item,
              );

              onChanged();
            },
            icon:
                const Icon(
              Icons
                  .add_circle_outline,
              color:
                  Colors.white,
              size:
                  23,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE PAYMENT
  // ============================================================

  Widget _buildMobilePaymentSummary() {
    return Container(
      padding:
          const EdgeInsets
              .all(
        15,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFF2B2B2B,
        ),
        borderRadius:
            BorderRadius.circular(
          8,
        ),
      ),
      child:
          Column(
        children: [
          _summaryRow(
            'Subtotal',
            'Rp ${_formatRupiah(subtotal.toInt())}',
          ),

          if (discountPercentage >
              0) ...[
            const SizedBox(
              height:
                  12,
            ),
            _summaryRow(
              'Discount ${_formatPercentage(discountPercentage)}%',
              '-Rp ${_formatRupiah(discountAmount.toInt())}',
            ),
          ],

          const SizedBox(
            height:
                12,
          ),

          _summaryRow(
            'Tax ${_formatPercentage(taxPercentage)}%',
            'Rp ${_formatRupiah(taxAmount.toInt())}',
          ),

          const SizedBox(
            height:
                10,
          ),

          const Divider(
            color:
                Colors.white54,
            height:
                1,
          ),

          const SizedBox(
            height:
                10,
          ),

          Row(
            children: [
              const Text(
                'Total',
                style:
                    TextStyle(
                  color:
                      Colors.white,
                  fontSize:
                      24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const Spacer(),

              Text(
                'Rp ${_formatRupiah(total.toInt())}',
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize:
                      22,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(
            height:
                30,
          ),

          const Align(
            alignment:
                Alignment
                    .centerLeft,
            child:
                Text(
              'Payment Method',
              style:
                  TextStyle(
                color:
                    Colors.white,
                fontSize:
                    12,
              ),
            ),
          ),

          const SizedBox(
            height:
                10,
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              _paymentMethod(
                Icons
                    .attach_money,
                'Cash',
              ),
              _paymentMethod(
                Icons
                    .credit_card,
                'Debit Card',
              ),
              _paymentMethod(
                Icons.qr_code,
                'E-Wallet',
              ),
            ],
          ),

          const SizedBox(
            height:
                16,
          ),

          SizedBox(
            width:
                double.infinity,
            height:
                36,
            child:
                ElevatedButton(
              onPressed:
                  cart.isEmpty
                      ? null
                      : _openPaymentPage,
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    Colors.white,
                foregroundColor:
                    Colors.black,
                disabledBackgroundColor:
                    Colors.white24,
                disabledForegroundColor:
                    Colors.white38,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
                padding:
                    EdgeInsets.zero,
              ),
              child:
                  const Text(
                'Place Order',
                style:
                    TextStyle(
                  fontSize:
                      13,
                ),
              ),
            ),
          ),
        ],
      ),
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
        selectedPaymentMethod ==
            title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod =
              title;
        });
      },
      child:
          Column(
        children: [
          Container(
            width:
                49,
            height:
                40,
            decoration:
                BoxDecoration(
              color:
                  selected
                      ? Colors.white
                      : Colors.transparent,
              border:
                  Border.all(
                color:
                    Colors.white,
              ),
              borderRadius:
                  BorderRadius.circular(
                9,
              ),
            ),
            child:
                Icon(
              icon,
              color:
                  selected
                      ? Colors.black
                      : Colors.white,
              size:
                  20,
            ),
          ),

          const SizedBox(
            height:
                5,
          ),

          Text(
            title,
            style:
                TextStyle(
              color:
                  Colors.white,
              fontSize:
                  10,
              fontWeight:
                  selected
                      ? FontWeight.bold
                      : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}