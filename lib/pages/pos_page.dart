import 'package:flutter/material.dart';
import '../pages/app_page_route.dart';

import '../models/category_model.dart';
import '../models/menu_model.dart';
import '../services/menu_service.dart';
import 'accounting_page.dart';
import 'cash_payment_page.dart';
import 'menu_management_page.dart';
import 'payment_page.dart';
import 'receipt_page.dart';
import 'transaction_page.dart';
import 'warehouse_page.dart';
import 'settings_page.dart';
import '../database/database_helper.dart';

part 'pos_page_logic.dart';
part 'pos_page_mobile_layout.dart';
part 'pos_page_mobile_navigation.dart';
part 'pos_page_mobile_order.dart';
part 'pos_page_ui.dart';

class PosPage extends StatefulWidget {
  const PosPage({
    super.key,
  });

  @override
  State<PosPage> createState() =>
      _PosPageState();
}

class _PosPageState
    extends State<PosPage> {
  int? selectedCategoryId;

  List<CategoryModel> categories = [];
  List<MenuModel> menuItems = [];

  bool isLoadingCategories = true;
  bool isLoadingMenu = false;
  bool isLoadingSettings = true;

  double taxPercentage = 10.0;
  double discountPercentage = 0.0;

  String? selectedPaymentMethod;

  final List<CartItem> cart = [];

  final TextEditingController
      searchController =
      TextEditingController();

  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    _loadCategories();
    _loadSettings();
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // MAIN
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
      body: LayoutBuilder(
        builder:
            (
          context,
          constraints,
        ) {
          final shortestSide =
              constraints
                  .biggest
                  .shortestSide;

          final isLandscape =
              constraints.maxWidth >
                  constraints.maxHeight;

          if (shortestSide < 600) {
            if (isLandscape) {
              return _buildMobileLandscapeLayout();
            }

            return _buildMobileLayout();
          }

          if (shortestSide < 1000) {
            return _buildTabletLayout();
          }

          return _buildDesktopLayout();
        },
      ),
    );
  }
}