import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() =>
      _SettingsPageState();
}

class _SettingsPageState
    extends State<SettingsPage> {
  final DatabaseHelper _database =
      DatabaseHelper.instance;

  final TextEditingController
      taxController =
      TextEditingController();

  final TextEditingController
      discountController =
      TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  @override
  void dispose() {
    taxController.dispose();
    discountController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD SETTINGS
  // ============================================================

  Future<void> _loadSettings() async {
    try {
      final settings =
          await _database.getSettings();

      if (!mounted) {
        return;
      }

      taxController.text =
          _formatValue(
        settings['tax_percentage'] ??
            10.0,
      );

      discountController.text =
          _formatValue(
        settings[
                'discount_percentage'] ??
            0.0,
      );

      setState(() {
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
        'Gagal memuat pengaturan: $e',
      );
    }
  }

  // ============================================================
  // SAVE SETTINGS
  // ============================================================

  Future<void> _saveSettings() async {
    final taxText =
        taxController.text.trim();

    final discountText =
        discountController.text.trim();

    // Kalau kosong, otomatis dianggap 0
    final tax =
        taxText.isEmpty
            ? 0.0
            : double.tryParse(
                taxText.replaceAll(
                  ',',
                  '.',
                ),
              );

    final discount =
        discountText.isEmpty
            ? 0.0
            : double.tryParse(
                discountText.replaceAll(
                  ',',
                  '.',
                ),
              );

    // Kalau bukan angka yang valid
    if (tax == null ||
        discount == null) {
      _showMessage(
        'Masukkan angka yang valid.',
      );
      return;
    }

    if (tax < 0 || tax > 100) {
      _showMessage(
        'Pajak harus antara 0% sampai 100%.',
      );
      return;
    }

    if (discount < 0 ||
        discount > 100) {
      _showMessage(
        'Diskon harus antara 0% sampai 100%.',
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await _database.updateSettings(
        taxPercentage: tax,
        discountPercentage:
            discount,
      );

      if (!mounted) {
        return;
      }

      // Tampilkan 0 pada field kalau sebelumnya kosong
      taxController.text =
          _formatValue(tax);

      discountController.text =
          _formatValue(discount);

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Pengaturan berhasil disimpan.',
            ),
          ),
        );

      await Future.delayed(
        const Duration(
          milliseconds: 400,
        ),
      );

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

      _showMessage(
        'Gagal menyimpan pengaturan: $e',
      );
    }
  }

  // ============================================================
  // FORMAT VALUE
  // ============================================================

  String _formatValue(
    double value,
  ) {
    if (value ==
        value.roundToDouble()) {
      return value
          .toInt()
          .toString();
    }

    return value.toString();
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
      appBar: AppBar(
        backgroundColor:
            const Color(
          0xFF101112,
        ),
        foregroundColor:
            Colors.white,
        elevation: 0,
        title:
            const Text(
          'Settings',
          style:
              TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
      body:
          LayoutBuilder(
        builder:
            (
          context,
          constraints,
        ) {
          return SafeArea(
            top:
                false,
            child:
                Center(
              child:
                  ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth:
                      700,
                ),
                child:
                    SingleChildScrollView(
                  padding:
                      EdgeInsets.fromLTRB(
                    constraints.maxWidth >=
                            600
                        ? 32
                        : 18,
                    18,
                    constraints.maxWidth >=
                            600
                        ? 32
                        : 18,
                    32,
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                              height:
                                  300,
                              child:
                                  Center(
                                child:
                                    CircularProgressIndicator(
                                  color:
                                      Colors.white,
                                ),
                              ),
                            )
                          : _buildContent(
                              constraints,
                            ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(
    BoxConstraints constraints,
  ) {
    final isLandscape =
        constraints.maxWidth >
            constraints.maxHeight;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Pengaturan Pembayaran',
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

        const SizedBox(
          height: 6,
        ),

        const Text(
          'Atur persentase pajak dan diskon yang digunakan pada transaksi.',
          style:
              TextStyle(
            color:
                Colors.white60,
            fontSize:
                13,
            height:
                1.4,
          ),
        ),

        const SizedBox(
          height: 24,
        ),

        if (isLandscape)
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child:
                    _buildTaxCard(),
              ),
              const SizedBox(
                width: 14,
              ),
              Expanded(
                child:
                    _buildDiscountCard(),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildTaxCard(),

              const SizedBox(
                height: 14,
              ),

              _buildDiscountCard(),
            ],
          ),

        const SizedBox(
          height: 24,
        ),

        _buildInfoCard(),

        const SizedBox(
          height: 24,
        ),

        SizedBox(
          width:
              double.infinity,
          height:
              50,
          child:
              ElevatedButton(
            onPressed:
                isSaving
                    ? null
                    : _saveSettings,
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
                isSaving
                    ? const SizedBox(
                        width:
                            20,
                        height:
                            20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth:
                              2,
                          color:
                              Colors.black,
                        ),
                      )
                    : const Text(
                        'Simpan Pengaturan',
                        style:
                            TextStyle(
                          fontSize:
                              14,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TAX CARD
  // ============================================================

  Widget _buildTaxCard() {
    return Container(
      padding:
          const EdgeInsets.all(
        18,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFF1A1B1D,
        ),
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        border:
            Border.all(
          color:
              Colors.white10,
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
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
                  Icons.percent,
                  color:
                      Colors.white,
                  size:
                      20,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              const Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      'Pajak',
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

                    SizedBox(
                      height: 3,
                    ),

                    Text(
                      'Persentase pajak transaksi',
                      style:
                          TextStyle(
                        color:
                            Colors.white54,
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
            height: 16,
          ),

          _buildPercentageField(
            controller:
                taxController,
            label:
                'Pajak (%)',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISCOUNT CARD
  // ============================================================

  Widget _buildDiscountCard() {
    return Container(
      padding:
          const EdgeInsets.all(
        18,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFF1A1B1D,
        ),
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        border:
            Border.all(
          color:
              Colors.white10,
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
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
                  Icons.local_offer_outlined,
                  color:
                      Colors.white,
                  size:
                      20,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              const Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      'Diskon',
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

                    SizedBox(
                      height: 3,
                    ),

                    Text(
                      'Persentase diskon transaksi',
                      style:
                          TextStyle(
                        color:
                            Colors.white54,
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
            height: 16,
          ),

          _buildPercentageField(
            controller:
                discountController,
            label:
                'Diskon (%)',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERCENTAGE FIELD
  // ============================================================

  Widget _buildPercentageField({
    required TextEditingController
        controller,
    required String label,
  }) {
    return TextField(
      controller:
          controller,
      keyboardType:
          const TextInputType
              .numberWithOptions(
        decimal:
            true,
      ),
      style:
          const TextStyle(
        color:
            Colors.white,
        fontSize:
            18,
        fontWeight:
            FontWeight.bold,
      ),
      decoration:
          InputDecoration(
        labelText:
            label,
        labelStyle:
            const TextStyle(
          color:
              Colors.white60,
          fontSize:
              13,
        ),
        suffixText:
            '%',
        suffixStyle:
            const TextStyle(
          color:
              Colors.white,
          fontSize:
              17,
          fontWeight:
              FontWeight.bold,
        ),
        filled:
            true,
        fillColor:
            const Color(
          0xFF242527,
        ),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            11,
          ),
          borderSide:
              BorderSide.none,
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            11,
          ),
          borderSide:
              BorderSide.none,
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            11,
          ),
          borderSide:
              const BorderSide(
            color:
                Colors.white54,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INFO
  // ============================================================

  Widget _buildInfoCard() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        15,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFF18191B,
        ),
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        border:
            Border.all(
          color:
              Colors.white10,
        ),
      ),
      child:
          const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color:
                Colors.white54,
            size:
                20,
          ),

          SizedBox(
            width: 10,
          ),

          Expanded(
            child:
                Text(
              'Nilai ini akan digunakan otomatis saat menghitung total transaksi.',
              style:
                  TextStyle(
                color:
                    Colors.white54,
                fontSize:
                    12,
                height:
                    1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

