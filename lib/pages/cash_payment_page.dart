import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CashPaymentPage extends StatefulWidget {
  final int totalAmount;

  const CashPaymentPage({
    super.key,
    required this.totalAmount,
  });

  @override
  State<CashPaymentPage> createState() =>
      _CashPaymentPageState();
}

class _CashPaymentPageState
    extends State<CashPaymentPage> {
  final TextEditingController cashController =
      TextEditingController();

  final TextEditingController nameController =
      TextEditingController();

  int cashReceived = 0;

  @override
  void dispose() {
    cashController.dispose();
    nameController.dispose();

    super.dispose();
  }

  void _onCashChanged(String value) {
    final cleanValue =
        value.replaceAll('.', '');

    final amount =
        int.tryParse(cleanValue) ?? 0;

    setState(() {
      cashReceived = amount;
    });
  }

  int get change {
    final result =
        cashReceived -
            widget.totalAmount;

    if (result < 0) {
      return 0;
    }

    return result;
  }

  int get shortage {
    final result =
        widget.totalAmount -
            cashReceived;

    if (result < 0) {
      return 0;
    }

    return result;
  }

  bool get isPaymentEnough {
    return cashReceived >=
        widget.totalAmount;
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
          number[i] + result;

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
        title: const Text(
          'Pembayaran Cash',
          style: TextStyle(
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
          const Text(
            'Ringkasan Pembayaran',
            style: TextStyle(
              color:
                  Colors.white,
              fontSize:
                  21,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          const Text(
            'Masukkan uang yang diberikan konsumen.',
            style: TextStyle(
              color:
                  Colors.white70,
              fontSize:
                  12,
            ),
          ),

          const SizedBox(
            height: 25,
          ),

          _buildTotalSection(),

          const SizedBox(
            height: 24,
          ),

          const Text(
            'Uang Diberikan',
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
                cashController,
            onChanged:
                _onCashChanged,
            keyboardType:
                TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter
                  .digitsOnly,
            ],
            style:
                const TextStyle(
              color:
                  Colors.white,
              fontSize:
                  16,
              fontWeight:
                  FontWeight.bold,
            ),
            decoration:
                InputDecoration(
              prefixText:
                  'Rp ',
              prefixStyle:
                  const TextStyle(
                color:
                    Colors.white70,
                fontSize:
                    16,
              ),
              hintText:
                  'Masukkan nominal',
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
            height: 10,
          ),

          if (cashReceived > 0 &&
              !isPaymentEnough)
            _buildShortageSection(),

          if (isPaymentEnough)
            _buildChangeSection(),

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
                  isPaymentEnough
                      ? _confirmPayment
                      : null,
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

  Widget _buildTotalSection() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        18,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFF1D1E1F),
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
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

          Text(
            'Rp ${_formatRupiah(widget.totalAmount)}',
            style:
                const TextStyle(
              color:
                  Colors.white,
              fontSize:
                  26,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeSection() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFF303132),
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
                42,
            height:
                42,
            decoration:
                BoxDecoration(
              color:
                  Colors.white,
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
            child:
                const Icon(
              Icons
                  .currency_exchange,
              color:
                  Colors.black,
              size:
                  21,
            ),
          ),

          const SizedBox(
            width:
                12,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                const Text(
                  'Kembalian',
                  style:
                      TextStyle(
                    color:
                        Colors.white70,
                    fontSize:
                        12,
                  ),
                ),

                const SizedBox(
                  height:
                      3,
                ),

                Text(
                  'Rp ${_formatRupiah(change)}',
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize:
                        19,
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

  Widget _buildShortageSection() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFF303132),
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
                42,
            height:
                42,
            decoration:
                BoxDecoration(
              color:
                  Colors.white,
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
            child:
                const Icon(
              Icons
                  .error_outline,
              color:
                  Colors.black,
              size:
                  21,
            ),
          ),

          const SizedBox(
            width:
                12,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                const Text(
                  'Uang masih kurang',
                  style:
                      TextStyle(
                    color:
                        Colors.white70,
                    fontSize:
                        12,
                  ),
                ),

                const SizedBox(
                  height:
                      3,
                ),

                Text(
                  'Rp ${_formatRupiah(shortage)}',
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize:
                        19,
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

  void _confirmPayment() {
    final buyerName =
        nameController.text.trim();

    Navigator.pop(
      context,
      {
        'cashReceived':
            cashReceived,
        'change':
            change,
        'buyerName':
            buyerName,
      },
    );
  }
}