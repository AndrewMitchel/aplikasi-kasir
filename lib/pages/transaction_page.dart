import 'dart:convert';

import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({
    super.key,
  });

  @override
  State<TransactionPage> createState() =>
      _TransactionPageState();
}

class _TransactionPageState
    extends State<TransactionPage> {
  List<Map<String, dynamic>> transactions = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadTransactions();
  }

  // ============================================================
  // LOAD TRANSACTIONS
  // ============================================================

  Future<void> _loadTransactions() async {
    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result =
          await DatabaseHelper.instance
              .getTransactions();

      if (!mounted) {
        return;
      }

      setState(() {
        transactions = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memuat transaksi: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // FORMAT RUPIAH
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
  // PARSE INT
  // ============================================================

  int _parseInt(
    dynamic value,
  ) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDateTime(
    dynamic value,
  ) {
    final text =
        value?.toString() ?? '';

    if (text.isEmpty) {
      return '-';
    }

    try {
      final date =
          DateTime.parse(text);

      final day =
          date.day.toString().padLeft(
                2,
                '0',
              );

      final month =
          date.month.toString().padLeft(
                2,
                '0',
              );

      final year =
          date.year.toString();

      final hour =
          date.hour.toString().padLeft(
                2,
                '0',
              );

      final minute =
          date.minute.toString().padLeft(
                2,
                '0',
              );

      return '$day-$month-$year • $hour:$minute';
    } catch (_) {
      return text;
    }
  }

  // ============================================================
  // PAYMENT METHOD
  // ============================================================

  IconData _paymentIcon(
    String method,
  ) {
    switch (method) {
      case 'Cash':
        return Icons.attach_money;

      case 'Debit Card':
      case 'Card':
        return Icons.credit_card;

      case 'E-Wallet':
      case 'QR':
        return Icons.qr_code;

      default:
        return Icons.payments_outlined;
    }
  }

  // ============================================================
  // ITEMS
  // ============================================================

  List<Map<String, dynamic>>
      _parseItems(
    dynamic value,
  ) {
    try {
      final decoded =
          jsonDecode(
        value?.toString() ?? '[]',
      );

      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(
              item,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ============================================================
  // TRANSACTION ROW
  // ============================================================

  Widget _buildTransaction(
    Map<String, dynamic> transaction,
  ) {
    final id =
        _parseInt(
      transaction['id'],
    );

    final total =
        _parseInt(
      transaction['total'],
    );

    final method =
        transaction['payment_method']
                ?.toString() ??
            '-';

    final buyerName =
        transaction['buyer_name']
                ?.toString()
                .trim() ??
            '';

    final createdAt =
        transaction['created_at'];

    final items =
        _parseItems(
      transaction['items_json'],
    );

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 18,
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .stretch,
        children: [
          // ======================================================
          // HEADER
          // ======================================================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      '#${id.toString().padLeft(3, '0')}',
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize:
                            15,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height:
                          3,
                    ),

                    Text(
                      _formatDateTime(
                        createdAt,
                      ),
                      style:
                          const TextStyle(
                        color:
                            Colors.white54,
                        fontSize:
                            10,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .end,
                children: [
                  Text(
                    _formatRupiah(
                      total,
                    ),
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize:
                          16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height:
                        3,
                  ),

                  Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        _paymentIcon(
                          method,
                        ),
                        color:
                            Colors.white54,
                        size:
                            13,
                      ),
                      const SizedBox(
                        width:
                            4,
                      ),
                      Text(
                        method,
                        style:
                            const TextStyle(
                          color:
                              Colors.white54,
                          fontSize:
                              10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(
            height:
                8,
          ),

          // ======================================================
          // BUYER
          // ======================================================

          Text(
            buyerName.isEmpty
                ? 'Atas nama: -'
                : 'Atas nama: $buyerName',
            style:
                const TextStyle(
              color:
                  Colors.white70,
              fontSize:
                  11,
            ),
          ),

          const SizedBox(
            height:
                10,
          ),

          // ======================================================
          // ORDER ITEMS
          // ======================================================

          if (items.isEmpty)
            const Text(
              'Tidak ada detail pesanan.',
              style:
                  TextStyle(
                color:
                    Colors.white38,
                fontSize:
                    11,
              ),
            )
          else
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children:
                  items.map(
                (
                  item,
                ) {
                  final name =
                      item['name']
                              ?.toString() ??
                          '-';

                  final quantity =
                      _parseInt(
                    item['quantity'],
                  );

                  final price =
                      _parseInt(
                    item['price'],
                  );

                  final itemTotal =
                      price *
                          quantity;

                  return Padding(
                    padding:
                        const EdgeInsets
                            .only(
                      bottom:
                          5,
                    ),
                    child:
                        Row(
                      children: [
                        Expanded(
                          child:
                              Text(
                            '${quantity}x $name',
                            maxLines:
                                1,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize:
                                  12,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width:
                              12,
                        ),

                        Text(
                          _formatRupiah(
                            itemTotal,
                          ),
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
                  );
                },
              ).toList(),
            ),

          const SizedBox(
            height:
                10,
          ),

          // ======================================================
          // DIVIDER
          // ======================================================

          const Divider(
            color:
                Colors.white12,
            height:
                1,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child:
          Column(
        mainAxisAlignment:
            MainAxisAlignment
                .center,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            color:
                Colors.white24,
            size:
                50,
          ),

          const SizedBox(
            height:
                12,
          ),

          const Text(
            'Belum ada transaksi',
            style:
                TextStyle(
              color:
                  Colors.white70,
              fontSize:
                  15,
            ),
          ),

          const SizedBox(
            height:
                4,
          ),

          const Text(
            'Transaksi yang sudah dibayar akan muncul di sini.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  Colors.white38,
              fontSize:
                  11,
            ),
          ),
        ],
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
          'Transaksi',
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
        actions: [
          IconButton(
            onPressed:
                _loadTransactions,
            icon:
                const Icon(
              Icons.refresh,
              color:
                  Colors.white,
            ),
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )
              : RefreshIndicator(
                  onRefresh:
                      _loadTransactions,
                  color:
                      const Color(
                    0xFF2C7BE5,
                  ),
                  child:
                      transactions.isEmpty
                          ? _buildEmptyState()
                          : LayoutBuilder(
                              builder:
                                  (
                                context,
                                constraints,
                              ) {
                                final isMobile =
                                    constraints.maxWidth <
                                        700;

                                final maxWidth =
                                    isMobile
                                        ? double.infinity
                                        : 800.0;

                                return SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding:
                                      EdgeInsets.symmetric(
                                    horizontal:
                                        isMobile
                                            ? 14
                                            : 24,
                                    vertical:
                                        16,
                                  ),
                                  child:
                                      Center(
                                    child:
                                        ConstrainedBox(
                                      constraints:
                                          BoxConstraints(
                                        maxWidth:
                                            maxWidth,
                                      ),
                                      child:
                                          Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children:
                                            transactions.map(
                                          (
                                            transaction,
                                          ) {
                                            return _buildTransaction(
                                              transaction,
                                            );
                                          },
                                        ).toList(),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
    );
  }
}