import 'dart:convert';

import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class AccountingPage extends StatefulWidget {
  const AccountingPage({
    super.key,
  });

  @override
  State<AccountingPage> createState() => _AccountingPageState();
}

enum _AccountingPeriod {
  daily,
  weekly,
  monthly,
}

class _ItemSales {
  final String name;
  final int quantity;
  final int total;

  const _ItemSales({
    required this.name,
    required this.quantity,
    required this.total,
  });
}

class _AccountingPageState extends State<AccountingPage> {
  DateTime selectedDate = DateTime.now();

  _AccountingPeriod selectedPeriod =
      _AccountingPeriod.daily;

  bool isLoading = true;

  List<_ItemSales> itemSales = [];

  int totalOmzet = 0;
  int totalItemsSold = 0;
  int totalTransactions = 0;

  @override
  void initState() {
    super.initState();

    _loadAccountingData();
  }

  // ============================================================
  // LOAD ACCOUNTING DATA
  // ============================================================

  Future<void> _loadAccountingData() async {
    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final transactions =
          await DatabaseHelper.instance.getTransactions();

      final start = _getPeriodStart(
        selectedDate,
      );

      final end = _getPeriodEnd(
        selectedDate,
      );

      int omzet = 0;
      int itemsSold = 0;
      int transactionsCount = 0;

      final Map<String, _ItemSales> salesMap = {};

      for (final transaction in transactions) {
        final createdAt =
            transaction['created_at']?.toString() ?? '';

        final transactionDate =
            _parseTransactionDate(
          createdAt,
        );

        if (transactionDate == null) {
          continue;
        }

        if (transactionDate.isBefore(start) ||
            transactionDate.isAfter(end)) {
          continue;
        }

        transactionsCount++;

        omzet += _parseInt(
          transaction['total'],
        );

        final itemsJson =
            transaction['items_json'];

        if (itemsJson == null) {
          continue;
        }

        try {
          final decoded =
              jsonDecode(
            itemsJson.toString(),
          );

          if (decoded is! List) {
            continue;
          }

          for (final item in decoded) {
            if (item is! Map) {
              continue;
            }

            final name =
                item['name']?.toString() ??
                    'Produk';

            final quantity =
                _parseInt(
              item['quantity'],
            );

            final price =
                _parseInt(
              item['price'],
            );

            if (quantity <= 0) {
              continue;
            }

            itemsSold += quantity;

            final itemTotal =
                price * quantity;

            if (salesMap.containsKey(name)) {
              final old =
                  salesMap[name]!;

              salesMap[name] =
                  _ItemSales(
                name: name,
                quantity:
                    old.quantity +
                        quantity,
                total:
                    old.total +
                        itemTotal,
              );
            } else {
              salesMap[name] =
                  _ItemSales(
                name: name,
                quantity: quantity,
                total: itemTotal,
              );
            }
          }
        } catch (_) {
          // Abaikan items_json yang tidak valid.
        }
      }

      final sortedSales =
          salesMap.values.toList();

      sortedSales.sort(
        (a, b) {
          final quantityCompare =
              b.quantity.compareTo(
            a.quantity,
          );

          if (quantityCompare != 0) {
            return quantityCompare;
          }

          return a.name.compareTo(
            b.name,
          );
        },
      );

      if (!mounted) {
        return;
      }

      setState(() {
        totalOmzet = omzet;
        totalItemsSold = itemsSold;
        totalTransactions =
            transactionsCount;
        itemSales = sortedSales;
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
        'Gagal memuat data: $e',
      );
    }
  }

  // ============================================================
  // PERIOD START
  // ============================================================

  DateTime _getPeriodStart(
    DateTime date,
  ) {
    final normalized =
        DateTime(
      date.year,
      date.month,
      date.day,
    );

    switch (selectedPeriod) {
      case _AccountingPeriod.daily:
        return normalized;

      case _AccountingPeriod.weekly:
        // Tanggal yang dipilih menjadi
        // hari pertama periode.
        //
        // Contoh:
        // 15 -> 15 sampai 21
        return normalized;

      case _AccountingPeriod.monthly:
        // Bulanan menggunakan bulan dan tahun.
        return DateTime(
          date.year,
          date.month,
          1,
        );
    }
  }

  // ============================================================
  // PERIOD END
  // ============================================================

  DateTime _getPeriodEnd(
    DateTime date,
  ) {
    final start =
        _getPeriodStart(
      date,
    );

    switch (selectedPeriod) {
      case _AccountingPeriod.daily:
        return DateTime(
          start.year,
          start.month,
          start.day,
          23,
          59,
          59,
          999,
        );

      case _AccountingPeriod.weekly:
        // 7 hari termasuk tanggal awal.
        //
        // Contoh:
        // 15,16,17,18,19,20,21
        return DateTime(
          start.year,
          start.month,
          start.day + 6,
          23,
          59,
          59,
          999,
        );

      case _AccountingPeriod.monthly:
        // Hari terakhir bulan.
        return DateTime(
          start.year,
          start.month + 1,
          0,
          23,
          59,
          59,
          999,
        );
    }
  }

  // ============================================================
  // PARSE TRANSACTION DATE
  // ============================================================

  DateTime? _parseTransactionDate(
    String value,
  ) {
    if (value.length < 10) {
      return null;
    }

    try {
      final datePart =
          value.substring(
        0,
        10,
      );

      final parts =
          datePart.split('-');

      if (parts.length != 3) {
        return null;
      }

      final year =
          int.parse(parts[0]);

      final month =
          int.parse(parts[1]);

      final day =
          int.parse(parts[2]);

      return DateTime(
        year,
        month,
        day,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // SELECT PERIOD
  // ============================================================

  Future<void> _selectPeriod(
    _AccountingPeriod period,
  ) async {
    if (selectedPeriod == period) {
      return;
    }

    setState(() {
      selectedPeriod = period;
    });

    await _loadAccountingData();
  }

  // ============================================================
  // SELECT DATE / MONTH
  // ============================================================

  Future<void> _selectDate() async {
    if (selectedPeriod ==
        _AccountingPeriod.monthly) {
      await _selectMonth();

      return;
    }

    final picked =
        await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(
        2020,
      ),
      lastDate: DateTime(
        2100,
      ),
      builder: (
        context,
        child,
      ) {
        return Theme(
          data:
              Theme.of(context).copyWith(
            colorScheme:
                const ColorScheme.dark(
              primary:
                  Color(0xFF4D8DFF),
              surface:
                  Color(0xFF191B1D),
            ),
            dialogTheme:
                const DialogThemeData(
              backgroundColor:
                  Color(0xFF191B1D),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) {
      return;
    }

    setState(() {
      selectedDate =
          DateTime(
        picked.year,
        picked.month,
        picked.day,
      );
    });

    await _loadAccountingData();
  }

  // ============================================================
  // SELECT MONTH
  // ============================================================

  Future<void> _selectMonth() async {
    int tempYear =
        selectedDate.year;

    int tempMonth =
        selectedDate.month;

    final result =
        await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              backgroundColor:
                  const Color(
                0xFF191B1D,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              title: const Text(
                'Pilih Bulan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  // ==================================================
                  // YEAR
                  // ==================================================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setDialogState(() {
                            tempYear--;
                          });
                        },
                        icon:
                            const Icon(
                          Icons
                              .chevron_left,
                          color:
                              Colors.white70,
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(
                          '$tempYear',
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 18,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setDialogState(() {
                            tempYear++;
                          });
                        },
                        icon:
                            const Icon(
                          Icons
                              .chevron_right,
                          color:
                              Colors.white70,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  GridView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing:
                          8,
                      mainAxisSpacing:
                          8,
                      childAspectRatio:
                          1.8,
                    ),
                    itemCount: 12,
                    itemBuilder:
                        (
                      context,
                      index,
                    ) {
                      final month =
                          index + 1;

                      final selected =
                          month ==
                                  tempMonth &&
                              tempYear ==
                                  selectedDate
                                      .year;

                      return InkWell(
                        borderRadius:
                            BorderRadius
                                .circular(
                          8,
                        ),
                        onTap: () {
                          setDialogState(() {
                            tempMonth =
                                month;
                          });
                        },
                        child:
                            Container(
                          alignment:
                              Alignment
                                  .center,
                          decoration:
                              BoxDecoration(
                            color: selected
                                ? const Color(
                                    0xFF4D8DFF,
                                  )
                                : const Color(
                                    0xFF24272A,
                                  ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              8,
                            ),
                          ),
                          child: Text(
                            _getShortMonth(
                              month,
                            ),
                            style:
                                TextStyle(
                              color:
                                  Colors.white,
                              fontSize:
                                  12,
                              fontWeight: selected
                                  ? FontWeight
                                      .bold
                                  : FontWeight
                                      .normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color:
                          Colors.white54,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      DateTime(
                        tempYear,
                        tempMonth,
                        1,
                      ),
                    );
                  },
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF4D8DFF,
                    ),
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        8,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Pilih',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) {
      return;
    }

    setState(() {
      selectedDate = result;
    });

    await _loadAccountingData();
  }

  // ============================================================
  // SHIFT MONTH
  // ============================================================

  Future<void> _shiftMonth(
    int direction,
  ) async {
    final newDate =
        DateTime(
      selectedDate.year,
      selectedDate.month + direction,
      1,
    );

    setState(() {
      selectedDate = newDate;
    });

    await _loadAccountingData();
  }

  // ============================================================
  // PERIOD LABEL
  // ============================================================

  String _getPeriodLabel() {
    switch (selectedPeriod) {
      case _AccountingPeriod.daily:
        return 'Harian';

      case _AccountingPeriod.weekly:
        return 'Mingguan';

      case _AccountingPeriod.monthly:
        return 'Bulanan';
    }
  }

  String _getDatePickerTitle() {
    switch (selectedPeriod) {
      case _AccountingPeriod.daily:
        return 'Pilih Tanggal';

      case _AccountingPeriod.weekly:
        return 'Pilih Tanggal Awal';

      case _AccountingPeriod.monthly:
        return 'Pilih Bulan';
    }
  }

  String _getPeriodRangeLabel() {
    final start =
        _getPeriodStart(
      selectedDate,
    );

    final end =
        _getPeriodEnd(
      selectedDate,
    );

    switch (selectedPeriod) {
      case _AccountingPeriod.daily:
        return _formatDate(
          start,
        );

      case _AccountingPeriod.weekly:
        return '${_formatDate(start)} - ${_formatDate(end)}';

      case _AccountingPeriod.monthly:
        return _formatMonth(
          start,
        );
    }
  }

  String _getPeriodDescription() {
    switch (selectedPeriod) {
      case _AccountingPeriod.daily:
        return 'Data penjualan untuk satu hari';

      case _AccountingPeriod.weekly:
        return 'Data penjualan selama 7 hari mulai dari tanggal yang dipilih';

      case _AccountingPeriod.monthly:
        return 'Data penjualan untuk satu bulan';
    }
  }

  String _getTotalOmzetLabel() {
    switch (selectedPeriod) {
      case _AccountingPeriod.daily:
        return 'Omzet Hari Ini';

      case _AccountingPeriod.weekly:
        return 'Omzet Mingguan';

      case _AccountingPeriod.monthly:
        return 'Omzet Bulanan';
    }
  }

  // ============================================================
  // FORMAT MONTH
  // ============================================================

  String _formatMonth(
    DateTime date,
  ) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }

  String _getShortMonth(
    int month,
  ) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return months[month - 1];
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(
    DateTime date,
  ) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  // ============================================================
  // FORMAT RUPIAH
  // ============================================================

  String _formatRupiah(
    int value,
  ) {
    final text =
        value.abs().toString();

    final buffer =
        StringBuffer();

    for (
      int i = 0;
      i < text.length;
      i++
    ) {
      if (
          i > 0 &&
          (text.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(
        text[i],
      );
    }

    return 'Rp ${buffer.toString()}';
  }

  // ============================================================
  // PARSE INT
  // ============================================================

  int _parseInt(
    dynamic value,
  ) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(
          value.toString(),
        ) ??
        double.tryParse(
              value.toString(),
            )?.toInt() ??
        0;
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
        content: Text(
          message,
        ),
      ),
    );
  }

  // ============================================================
  // PERIOD DROPDOWN
  // ============================================================

  Widget _buildPeriodDropdown() {
    return PopupMenuButton<
        _AccountingPeriod>(
      initialValue:
          selectedPeriod,
      onSelected:
          _selectPeriod,
      color:
          const Color(0xFF191B1D),
      offset:
          const Offset(0, 45),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          10,
        ),
      ),
      itemBuilder:
          (context) => [
        _buildPeriodMenuItem(
          _AccountingPeriod.daily,
          'Harian',
          Icons.today_outlined,
        ),
        _buildPeriodMenuItem(
          _AccountingPeriod.weekly,
          'Mingguan',
          Icons.date_range_outlined,
        ),
        _buildPeriodMenuItem(
          _AccountingPeriod.monthly,
          'Bulanan',
          Icons.calendar_month_outlined,
        ),
      ],
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 9,
        ),
        decoration:
            BoxDecoration(
          border:
              Border.all(
            color: Colors.white24,
          ),
          borderRadius:
              BorderRadius.circular(
            8,
          ),
        ),
        child: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.date_range_outlined,
              color:
                  Colors.white70,
              size: 17,
            ),
            const SizedBox(
              width: 6,
            ),
            Text(
              _getPeriodLabel(),
              style:
                  const TextStyle(
                color:
                    Colors.white,
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
            const SizedBox(
              width: 4,
            ),
            const Icon(
              Icons
                  .keyboard_arrow_down,
              color:
                  Colors.white70,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<
      _AccountingPeriod>
      _buildPeriodMenuItem(
    _AccountingPeriod period,
    String title,
    IconData icon,
  ) {
    return PopupMenuItem<
        _AccountingPeriod>(
      value: period,
      child: Row(
        children: [
          Icon(
            icon,
            color: period ==
                    selectedPeriod
                ? const Color(
                    0xFF4D8DFF,
                  )
                : Colors.white70,
            size: 18,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            title,
            style: TextStyle(
              color: period ==
                      selectedPeriod
                  ? const Color(
                      0xFF4D8DFF,
                    )
                  : Colors.white,
              fontWeight: period ==
                      selectedPeriod
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MONTH NAVIGATION
  // ============================================================

  Widget _buildMonthlyNavigation() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      decoration:
          BoxDecoration(
        border:
            Border.all(
          color: Colors.white24,
        ),
        borderRadius:
            BorderRadius.circular(
          8,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () =>
                _shiftMonth(-1),
            tooltip:
                'Bulan sebelumnya',
            icon:
                const Icon(
              Icons.chevron_left,
              color:
                  Colors.white70,
              size: 21,
            ),
          ),
          Text(
            _formatMonth(
              selectedDate,
            ),
            style:
                const TextStyle(
              color:
                  Colors.white,
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () =>
                _shiftMonth(1),
            tooltip:
                'Bulan berikutnya',
            icon:
                const Icon(
              Icons.chevron_right,
              color:
                  Colors.white70,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE CARD
  // ============================================================

  Widget _buildDateCard(
    bool isMobile,
  ) {
    final range =
        _getPeriodRangeLabel();

    return Container(
      padding:
          const EdgeInsets.all(
        12,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFF191B1D),
        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons
                          .calendar_month_outlined,
                      color:
                          Colors.white70,
                      size: 19,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: selectedPeriod ==
                              _AccountingPeriod
                                  .monthly
                          ? _buildMonthlyNavigation()
                          : Text(
                              range,
                              maxLines: 2,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 15,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    _buildPeriodDropdown(),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width:
                      double.infinity,
                  child:
                      OutlinedButton(
                    onPressed:
                        _selectDate,
                    style:
                        OutlinedButton
                            .styleFrom(
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
                            BorderRadius
                                .circular(
                          8,
                        ),
                      ),
                    ),
                    child: Text(
                      _getDatePickerTitle(),
                      style:
                          const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                const Icon(
                  Icons
                      .calendar_month_outlined,
                  color:
                      Colors.white70,
                  size: 19,
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: selectedPeriod ==
                          _AccountingPeriod
                              .monthly
                      ? _buildMonthlyNavigation()
                      : Text(
                          range,
                          maxLines: 2,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 15,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                ),
                OutlinedButton(
                  onPressed:
                      _selectDate,
                  style:
                      OutlinedButton
                          .styleFrom(
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
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        8,
                      ),
                    ),
                  ),
                  child: Text(
                    _getDatePickerTitle(),
                    style:
                        const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                _buildPeriodDropdown(),
              ],
            ),
    );
  }

  // ============================================================
  // ITEM ROW
  // ============================================================

  Widget _buildItemRow(
    _ItemSales item,
    bool isLast,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration:
          BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom:
                    BorderSide(
                  color:
                      Colors.white10,
                ),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  const TextStyle(
                color:
                    Colors.white,
                fontSize: 13,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          SizedBox(
            width: 45,
            child: Text(
              '${item.quantity}',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          SizedBox(
            width: 105,
            child: Text(
              _formatRupiah(
                item.total,
              ),
              textAlign:
                  TextAlign.right,
              style:
                  const TextStyle(
                color:
                    Colors.white,
                fontSize: 13,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SALES TABLE
  // ============================================================

  Widget _buildSalesTable(
    bool isMobile,
  ) {
    return Container(
      decoration:
          BoxDecoration(
        color:
            const Color(0xFF191B1D),
        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Produk',
                    style:
                        TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 45,
                  child: Text(
                    'Qty',
                    textAlign:
                        TextAlign.center,
                    style:
                        TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 105,
                  child: Text(
                    'Total',
                    textAlign:
                        TextAlign.right,
                    style:
                        TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (itemSales.isEmpty)
            const Padding(
              padding:
                  EdgeInsets.all(
                30,
              ),
              child: Center(
                child: Text(
                  'Belum ada penjualan pada periode ini',
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    color:
                        Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            ...List.generate(
              itemSales.length,
              (index) {
                return _buildItemRow(
                  itemSales[index],
                  index ==
                      itemSales.length -
                          1,
                );
              },
            ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFF191B1D),
        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFF4D8DFF,
              ).withValues(
                alpha: 0.12,
              ),
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
            child: Icon(
              icon,
              color:
                  const Color(
                0xFF4D8DFF,
              ),
              size: 21,
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    color:
                        Colors.white54,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 18,
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
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF101214),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF101214),
        elevation: 0,
        title: const Text(
          'Accounting',
          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final isMobile =
              constraints.maxWidth <
                  700;

          return SafeArea(
            child:
                RefreshIndicator(
              onRefresh:
                  _loadAccountingData,
              color:
                  const Color(
                0xFF4D8DFF,
              ),
              backgroundColor:
                  const Color(
                0xFF191B1D,
              ),
              child:
                  SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    EdgeInsets.all(
                  isMobile
                      ? 14
                      : 20,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .stretch,
                  children: [
                    _buildDateCard(
                      isMobile,
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    if (isLoading)
                      const Padding(
                        padding:
                            EdgeInsets
                                .all(
                          50,
                        ),
                        child:
                            Center(
                          child:
                              CircularProgressIndicator(
                            color:
                                Color(
                              0xFF4D8DFF,
                            ),
                          ),
                        ),
                      )
                    else ...[
                      Text(
                        _getPeriodDescription(),
                        style:
                            const TextStyle(
                          color:
                              Colors.white54,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      if (isMobile)
                        Column(
                          children: [
                            _buildSummaryCard(
                              title:
                                  _getTotalOmzetLabel(),
                              value:
                                  _formatRupiah(
                                totalOmzet,
                              ),
                              icon: Icons
                                  .payments_outlined,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            _buildSummaryCard(
                              title:
                                  'Total Transaksi',
                              value:
                                  '$totalTransactions',
                              icon: Icons
                                  .receipt_long_outlined,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            _buildSummaryCard(
                              title:
                                  'Item Terjual',
                              value:
                                  '$totalItemsSold',
                              icon: Icons
                                  .shopping_bag_outlined,
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child:
                                  _buildSummaryCard(
                                title:
                                    _getTotalOmzetLabel(),
                                value:
                                    _formatRupiah(
                                  totalOmzet,
                                ),
                                icon: Icons
                                    .payments_outlined,
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child:
                                  _buildSummaryCard(
                                title:
                                    'Total Transaksi',
                                value:
                                    '$totalTransactions',
                                icon: Icons
                                    .receipt_long_outlined,
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child:
                                  _buildSummaryCard(
                                title:
                                    'Item Terjual',
                                value:
                                    '$totalItemsSold',
                                icon: Icons
                                    .shopping_bag_outlined,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(
                        height: 16,
                      ),

                      Text(
                        'Penjualan Produk',
                        style:
                            TextStyle(
                          color:
                              Colors.white,
                          fontSize:
                              isMobile
                                  ? 16
                                  : 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      _buildSalesTable(
                        isMobile,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}