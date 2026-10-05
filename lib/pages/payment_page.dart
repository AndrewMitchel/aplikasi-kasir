import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final int totalAmount;
  final String paymentMethod;

  const PaymentPage({
    super.key,
    required this.totalAmount,
    required this.paymentMethod,
  });

  @override
  State<PaymentPage> createState() =>
      _PaymentPageState();
}

class _PaymentPageState
    extends State<PaymentPage> {
  final TextEditingController
      nameController =
      TextEditingController();

  @override
  void dispose() {
    nameController.dispose();

    super.dispose();
  }

  String _formatRupiah(int value) {
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

      if (
        count == 3 &&
        i != 0
      ) {
        result =
            '.$result';

        count = 0;
      }
    }

    return result;
  }

  IconData get paymentIcon {
    if (widget.paymentMethod ==
        'Debit Card') {
      return Icons.credit_card;
    }

    return Icons.qr_code;
  }

  String get pageTitle {
    if (widget.paymentMethod ==
        'Debit Card') {
      return 'Pembayaran Card';
    }

    return 'Pembayaran QR';
  }

  String get description {
    if (widget.paymentMethod ==
        'Debit Card') {
      return 'Selesaikan pembayaran menggunakan kartu.';
    }

    return 'Selesaikan pembayaran menggunakan QR.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF101112),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF101112),
        foregroundColor:
            Colors.white,
        elevation: 0,
        title: Text(
          pageTitle,
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder:
              (
            context,
            constraints,
          ) {
            final isMobile =
                constraints.maxWidth <
                    600;

            return SingleChildScrollView(
              padding:
                  EdgeInsets.all(
                isMobile
                    ? 16
                    : 28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 600,
                  ),
                  child:
                      _buildPaymentCard(
                    isMobile,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaymentCard(
    bool isMobile,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          EdgeInsets.all(
        isMobile
            ? 18
            : 25,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFF2B2B2B),
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width:
                    46,
                height:
                    46,
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child:
                    Icon(
                  paymentIcon,
                  color:
                      Colors.black,
                  size:
                      23,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      widget.paymentMethod,
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize:
                            18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      description,
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
            ],
          ),

          const SizedBox(
            height: 28,
          ),

          const Text(
            'Total Order',
            style: TextStyle(
              color:
                  Colors.white70,
              fontSize:
                  12,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Container(
            width:
                double.infinity,
            padding:
                const EdgeInsets.all(
              18,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFF1D1E1F,
              ),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child:
                Text(
              'Rp ${_formatRupiah(widget.totalAmount)}',
              style:
                  const TextStyle(
                color:
                    Colors.white,
                fontSize:
                    27,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(
            height: 25,
          ),

          const Text(
            'Pembelian Atas Nama',
            style: TextStyle(
              color:
                  Colors.white,
              fontSize:
                  15,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          TextField(
            controller:
                nameController,
            textCapitalization:
                TextCapitalization
                    .words,
            style:
                const TextStyle(
              color:
                  Colors.white,
              fontSize:
                  15,
            ),
            decoration:
                InputDecoration(
              hintText:
                  'Masukkan nama pembeli',
              hintStyle:
                  const TextStyle(
                color:
                    Colors.white38,
                fontSize:
                    14,
              ),
              filled:
                  true,
              fillColor:
                  const Color(
                0xFF1D1E1F,
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
              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
                borderSide:
                    BorderSide.none,
              ),
              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
                borderSide:
                    const BorderSide(
                  color:
                      Colors.white54,
                ),
              ),
              contentPadding:
                  const EdgeInsets
                      .symmetric(
                horizontal:
                    15,
                vertical:
                    15,
              ),
            ),
          ),

          const SizedBox(
            height: 30,
          ),

          SizedBox(
            width:
                double.infinity,
            height:
                46,
            child:
                ElevatedButton(
              onPressed:
                  _confirmPayment,
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    Colors.white,
                foregroundColor:
                    Colors.black,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
              child:
                  const Text(
                'Konfirmasi Pembayaran',
                style:
                    TextStyle(
                  fontSize:
                      13,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmPayment() {
    final buyerName =
        nameController.text.trim();

    Navigator.pop(
      context,
      {
        'paymentMethod':
            widget.paymentMethod,
        'buyerName':
            buyerName,
      },
    );
  }
}