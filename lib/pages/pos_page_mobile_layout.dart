part of 'pos_page.dart';

extension _PosPageMobileLayout on _PosPageState {
  // ============================================================
  // MOBILE PORTRAIT
  // ============================================================

  Widget _buildMobileLayout() {
    return SafeArea(
      child: Column(
        children: [
          _buildMobileHeader(),

          Expanded(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    12,
                    6,
                    12,
                    0,
                  ),
                  child:
                      _buildMobileSearch(),
                ),

                const SizedBox(
                  height: 14,
                ),

                const Padding(
                  padding:
                      EdgeInsets
                          .symmetric(
                    horizontal: 12,
                  ),
                  child: Align(
                    alignment:
                        Alignment
                            .centerLeft,
                    child: Text(
                      'Categories',
                      style:
                          TextStyle(
                        color:
                            Colors.white,
                        fontSize:
                            18,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                _buildMobileCategories(),

                const SizedBox(
                  height: 14,
                ),

                Padding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 12,
                  ),
                  child: Align(
                    alignment:
                        Alignment
                            .centerLeft,
                    child: Text(
                      _getSelectedCategoryName(),
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize:
                            18,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 12,
                    ),
                    child:
                        _buildMenuGrid(
                      mobile:
                          true,
                      tablet:
                          false,
                    ),
                  ),
                ),
              ],
            ),
          ),

          _buildMobileCartBar(),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE SEARCH
  // ============================================================

  Widget _buildMobileSearch() {
    return SizedBox(
      width:
          double.infinity,
      height:
          44,
      child:
          Container(
        decoration:
            BoxDecoration(
          color:
              const Color(
            0xFFE4E4E4,
          ),
          borderRadius:
              BorderRadius.circular(
            22,
          ),
        ),
        child:
            TextField(
          controller:
              searchController,
          onChanged:
              (value) {
            setState(() {
              searchQuery =
                  value;
            });
          },
          style:
              const TextStyle(
            fontSize:
                13,
            color:
                Colors.black,
          ),
          decoration:
              const InputDecoration(
            prefixIcon:
                Icon(
              Icons.search,
              color:
                  Colors.black,
              size:
                  21,
            ),
            hintText:
                'Search menu',
            hintStyle:
                TextStyle(
              color:
                  Colors.grey,
              fontSize:
                  13,
            ),
            border:
                InputBorder.none,
            contentPadding:
                EdgeInsets
                    .symmetric(
              vertical:
                  11,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MOBILE CATEGORIES
  // ============================================================

  Widget _buildMobileCategories() {
    if (isLoadingCategories) {
      return const SizedBox(
        height:
            108,
        child:
            Center(
          child:
              CircularProgressIndicator(
            color:
                Colors.white,
          ),
        ),
      );
    }

    return SizedBox(
      width:
          double.infinity,
      height:
          108,
      child:
          ListView
              .separated(
        padding:
            const EdgeInsets
                .symmetric(
          horizontal:
              12,
        ),
        scrollDirection:
            Axis.horizontal,
        itemCount:
            categories.length,
        separatorBuilder:
            (
          _,
          _,
        ) {
          return const SizedBox(
            width:
                10,
          );
        },
        itemBuilder:
            (
          context,
          index,
        ) {
          return SizedBox(
            width:
                145,
            child:
                _buildCategoryCard(
              categories[
                  index],
              mobile:
                  true,
            ),
          );
        },
      ),
    );
  }

  String _getSelectedCategoryName() {
    if (selectedCategoryId ==
        null) {
      return '';
    }

    for (
      final category
          in categories
    ) {
      if (category.id ==
          selectedCategoryId) {
        return category.name;
      }
    }

    return '';
  }

  // ============================================================
  // MOBILE LANDSCAPE
  // ============================================================

  Widget _buildMobileLandscapeLayout() {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            child:
                Column(
              children: [
                _buildMobileLandscapeHeader(),

                Expanded(
                  child:
                      Padding(
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      12,
                      4,
                      12,
                      8,
                    ),
                    child:
                        Column(
                      children: [
                        _buildMobileLandscapeSearch(),

                        const SizedBox(
                          height:
                              8,
                        ),

                        const Align(
                          alignment:
                              Alignment
                                  .centerLeft,
                          child:
                              Text(
                            'Categories',
                            style:
                                TextStyle(
                              color:
                                  Colors.white,
                              fontSize:
                                  15,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height:
                              5,
                        ),

                        _buildMobileLandscapeCategories(),

                        const SizedBox(
                          height:
                              8,
                        ),

                        Align(
                          alignment:
                              Alignment
                                  .centerLeft,
                          child:
                              Text(
                            _getSelectedCategoryName(),
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
                        ),

                        const SizedBox(
                          height:
                              5,
                        ),

                        Expanded(
                          child:
                              _buildMenuGrid(
                            mobile:
                                true,
                            tablet:
                                false,
                            landscape:
                                true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width:
                280,
            child:
                Container(
              height:
                  double.infinity,
              padding:
                  const EdgeInsets
                      .fromLTRB(
                12,
                10,
                12,
                12,
              ),
              color:
                  const Color(
                0xFF101112,
              ),
              child:
                  _buildMobileLandscapeOrderPanel(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLandscapeSearch() {
    return SizedBox(
      width:
          double.infinity,
      height:
          36,
      child:
          Container(
        decoration:
            BoxDecoration(
          color:
              const Color(
            0xFFE4E4E4,
          ),
          borderRadius:
              BorderRadius.circular(
            19,
          ),
        ),
        child:
            TextField(
          controller:
              searchController,
          onChanged:
              (value) {
            setState(() {
              searchQuery =
                  value;
            });
          },
          style:
              const TextStyle(
            color:
                Colors.black,
            fontSize:
                11,
          ),
          decoration:
              const InputDecoration(
            prefixIcon:
                Icon(
              Icons.search,
              color:
                  Colors.black,
              size:
                  18,
            ),
            hintText:
                'Search menu',
            hintStyle:
                TextStyle(
              color:
                  Colors.grey,
              fontSize:
                  11,
            ),
            border:
                InputBorder.none,
            contentPadding:
                EdgeInsets
                    .symmetric(
              vertical:
                  8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLandscapeCategories() {
    if (isLoadingCategories) {
      return const SizedBox(
        height:
            78,
        child:
            Center(
          child:
              CircularProgressIndicator(
            color:
                Colors.white,
          ),
        ),
      );
    }

    return SizedBox(
      width:
          double.infinity,
      height:
          78,
      child:
          ListView
              .separated(
        padding:
            EdgeInsets.zero,
        scrollDirection:
            Axis.horizontal,
        itemCount:
            categories.length,
        separatorBuilder:
            (
          _,
          _,
        ) {
          return const SizedBox(
            width:
                8,
          );
        },
        itemBuilder:
            (
          context,
          index,
        ) {
          return SizedBox(
            width:
                112,
            child:
                _buildLandscapeCategoryCard(
              categories[
                  index],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLandscapeCategoryCard(
    CategoryModel category,
  ) {
    final selected =
        selectedCategoryId ==
            category.id;

    return GestureDetector(
      onTap: () {
        _selectCategory(
          category.id,
        );
      },
      child:
          Container(
        padding:
            const EdgeInsets
                .all(
          9,
        ),
        decoration:
            BoxDecoration(
          color:
              Color(
            category
                .colorValue,
          ),
          borderRadius:
              BorderRadius.circular(
            13,
          ),
          border: selected
              ? Border.all(
                  color:
                      Colors.white,
                  width:
                      2,
                )
              : null,
        ),
        child:
            Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Icon(
              _getCategoryIcon(
                category
                    .iconName,
              ),
              color:
                  const Color(
                0xFF202124,
              ),
              size:
                  18,
            ),

            const Spacer(),

            Text(
              category.name,
              maxLines:
                  1,
              overflow:
                  TextOverflow
                      .ellipsis,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF202124,
                ),
                fontSize:
                    14,
              ),
            ),

            const SizedBox(
              height:
                  1,
            ),

            Text(
              '${category.itemCount} items',
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF303030,
                ),
                fontSize:
                    8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}