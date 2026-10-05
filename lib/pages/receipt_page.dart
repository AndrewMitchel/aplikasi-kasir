import 'dart:convert';

import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class ReceiptPage extends StatefulWidget {
  final int transactionId;

  const ReceiptPage({
    super.key,
    required this.transactionId,
  });

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  Map<String, dynamic>? _transaction;
  List<Map<String, dynamic>> _items = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    try {
      final transaction =
          await DatabaseHelper.instance.getTransactionById(
        widget.transactionId,
      );

      if (transaction != null) {
        final rawItems = transaction['items_json'];

        List<Map<String, dynamic>> items = [];

        if (rawItems != null && rawItems.toString().isNotEmpty) {
          final decoded = jsonDecode(rawItems.toString());

          if (decoded is List) {
            items = decoded
                .map(
                  (item) => Map<String, dynamic>.from(item as Map),
                )
                .toList();
          }
        }

        if (mounted) {
          setState(() {
            _transaction = transaction;
            _items = items;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memuat struk: $e',
            ),
          ),
        );
      }
    }
  }

  String _formatRupiah(dynamic value) {
    final number = int.tryParse(
          value?.toString() ?? '0',
        ) ??
        0;

    final text = number.toString();

    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final positionFromEnd = text.length - i;

      buffer.write(text[i]);

      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return 'Rp ${buffer.toString()}';
  }

  String _formatDate(dynamic value) {
    if (value == null) {
      return '-';
    }

    try {
      final date = DateTime.parse(
        value.toString(),
      ).toLocal();

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return '$day/$month/$year $hour:$minute';
    } catch (_) {
      return value.toString();
    }
  }

  String _paymentMethodLabel(dynamic value) {
    final method = value?.toString() ?? '';

    switch (method.toLowerCase()) {
      case 'e-wallet':
      case 'ewallet':
      case 'qr':
      case 'qris':
        return 'QRIS';

      case 'debit card':
      case 'card':
      case 'credit card':
        return 'Debit Card';

      case 'cash':
        return 'Cash';

      default:
        return method.isEmpty ? '-' : method;
    }
  }

  int _intValue(String key) {
    if (_transaction == null) {
      return 0;
    }

    return int.tryParse(
          _transaction![key]?.toString() ?? '0',
        ) ??
        0;
  }

  double _doubleValue(String key) {
    if (_transaction == null) {
      return 0;
    }

    return double.tryParse(
          _transaction![key]?.toString() ?? '0',
        ) ??
        0;
  }

  bool get _isCash {
    final method = _transaction?['payment_method']
            ?.toString()
            .toLowerCase() ??
        '';

    return method == 'cash';
  }

  void _printReceipt() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Fitur printer struk akan disambungkan setelah pengaturan printer selesai.',
        ),
      ),
    );
  }

  Widget _buildReceiptItem(
    Map<String, dynamic> item,
  ) {
    final name = item['name']?.toString() ?? '-';

    final price = int.tryParse(
          item['price']?.toString() ?? '0',
        ) ??
        0;

    final quantity = int.tryParse(
          item['quantity']?.toString() ?? '0',
        ) ??
        0;

    final total = price * quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF202124),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$quantity x ${_formatRupiah(price)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _formatRupiah(total),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF202124),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String title,
    String value, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: bold ? 15 : 13,
                fontWeight:
                    bold ? FontWeight.bold : FontWeight.normal,
                color: const Color(0xFF333333),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 15 : 13,
              fontWeight:
                  bold ? FontWeight.bold : FontWeight.normal,
              color: const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101112),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101112),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Receipt',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _transaction == null
              ? _buildErrorState()
              : _buildReceipt(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 60,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            const Text(
              'Data transaksi tidak ditemukan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 220,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Kembali',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceipt() {
    final subtotal = _intValue('subtotal');
    final discountAmount = _intValue('discount_amount');
    final taxAmount = _intValue('tax_amount');
    final total = _intValue('total');

    final cashReceived = _intValue('cash_received');
    final changeAmount = _intValue('change_amount');

    final discountPercentage =
        _doubleValue('discount_percentage');

    final taxPercentage =
        _doubleValue('tax_percentage');

    final paymentMethod =
        _paymentMethodLabel(_transaction!['payment_method']);

    final buyerName =
        _transaction!['buyer_name']?.toString() ?? '';

    final createdAt =
        _formatDate(_transaction!['created_at']);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          30,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            child: Column(
              children: [
                // ==================================================
                // RECEIPT
                // ==================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    28,
                    24,
                    28,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.20),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
                    children: [
                      // ==================================================
                      // LOGO STRUK
                      // ==================================================

                      Image.asset(
                        'assets/icon/Struk.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 8),

                      // ==================================================
                      // NAMA CAFE
                      // ==================================================

                      const Text(
                        'KOTAK KASIR CAFE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF202124),
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        'Jl. Alamat Cafe',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                      ),

                      const Text(
                        'Indonesia',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        createdAt,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),

                      if (buyerName.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Customer: $buyerName',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF777777),
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),

                      const Divider(
                        color: Color(0xFFDDDDDD),
                      ),

                      const SizedBox(height: 8),

                      // ==================================================
                      // ITEM
                      // ==================================================

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Pesanan',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF202124),
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),

                      if (_items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          child: Text(
                            'Tidak ada item.',
                            style: TextStyle(
                              color: Color(0xFF777777),
                            ),
                          ),
                        )
                      else
                        ..._items.map(
                          _buildReceiptItem,
                        ),

                      const SizedBox(height: 8),

                      const Divider(
                        color: Color(0xFFDDDDDD),
                      ),

                      const SizedBox(height: 8),

                      // ==================================================
                      // SUMMARY
                      // ==================================================

                      _buildSummaryRow(
                        'Subtotal',
                        _formatRupiah(subtotal),
                      ),

                      if (discountAmount > 0)
                        _buildSummaryRow(
                          'Diskon ${discountPercentage > 0 ? '(${discountPercentage.toStringAsFixed(discountPercentage % 1 == 0 ? 0 : 2)}%)' : ''}',
                          '- ${_formatRupiah(discountAmount)}',
                        ),

                      if (taxAmount > 0)
                        _buildSummaryRow(
                          'Pajak ${taxPercentage > 0 ? '(${taxPercentage.toStringAsFixed(taxPercentage % 1 == 0 ? 0 : 2)}%)' : ''}',
                          _formatRupiah(taxAmount),
                        ),

                      const SizedBox(height: 5),

                      const Divider(
                        color: Color(0xFFDDDDDD),
                      ),

                      const SizedBox(height: 5),

                      _buildSummaryRow(
                        'TOTAL',
                        _formatRupiah(total),
                        bold: true,
                      ),

                      const SizedBox(height: 15),

                      // ==================================================
                      // PAYMENT
                      // ==================================================

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Pembayaran',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF202124),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      _buildSummaryRow(
                        'Metode Pembayaran',
                        paymentMethod,
                      ),

                      const SizedBox(height: 3),

                      if (_isCash) ...[
                        _buildSummaryRow(
                          'Total to Pay',
                          _formatRupiah(total),
                        ),
                        _buildSummaryRow(
                          'Total Payment',
                          _formatRupiah(cashReceived),
                        ),
                        _buildSummaryRow(
                          'Kembalian',
                          _formatRupiah(changeAmount),
                          bold: true,
                        ),
                      ] else ...[
                        _buildSummaryRow(
                          'Total Payment',
                          _formatRupiah(total),
                          bold: true,
                        ),
                      ],

                      const SizedBox(height: 20),

                      const Divider(
                        color: Color(0xFFDDDDDD),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        'Terima kasih atas pembelian Anda!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF555555),
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'Simpan struk ini sebagai bukti pembayaran.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // BUTTON CETAK STRUK
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _printReceipt,
                    icon: const Icon(
                      Icons.print_rounded,
                    ),
                    label: const Text(
                      'Cetak Struk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF2C7BE5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // BUTTON KEMBALI
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(
                        color: Colors.white30,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Kembali',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}