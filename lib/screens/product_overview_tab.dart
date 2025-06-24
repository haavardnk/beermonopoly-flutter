import 'package:flutter/material.dart' hide SearchBar;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_fadein/flutter_fadein.dart';

import '../widgets/products/product_list.dart';
import '../providers/filter.dart';
import '../widgets/drawer/app_drawer.dart';
import '../widgets/products/product_overview_bottom_filter_sheet.dart';
import '../widgets/products/product_overview_search_bar.dart';
import '../widgets/products/product_overview_release_sort.dart';
import '../widgets/products/product_overview_release_product_selection.dart';
import '../models/release.dart';

class ProductOverviewTab extends StatelessWidget {
  final Release? release;

  const ProductOverviewTab({Key? key, this.release}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _currentIndex = 0;
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: release != null
            ? FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  release!.releaseDate != null
                      ? toBeginningOfSentenceCase(DateFormat.yMMMMEEEEd('nb_NO').format(release!.releaseDate!))
                      : release!.name,
                ),
              )
            : Consumer<Filter>(
                builder: (context, filter, _) => FadeIn(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      _currentIndex == 0
                          ? filter.selectedStores.isEmpty
                              ? 'Alle Butikker'
                              : filter.selectedStores.length == 1
                                  ? filter.selectedStores[0]
                                  : 'Valgte butikker: ${filter.selectedStores.length}'
                          : _currentIndex == 1
                              ? 'Nyhetslanseringer'
                              : _currentIndex == 2
                                  ? 'Velg Butikk'
                                  : 'Handleliste',
                    ),
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                ),
              ),
        actions: [
          release == null
              ? const ProductOverviewBottomFilterSheet()
              : ProductOverviewReleaseSort(release!),
        ],
        bottom: release == null
            ? const PreferredSize(
                child: ProductOverviewSearchBar(),
                preferredSize: Size.fromHeight(kToolbarHeight),
              )
            : (release != null && release!.productSelections.length > 1)
                ? PreferredSize(
                    child: ProductOverviewReleaseProductSelection(
                        release: release),
                    preferredSize: const Size.fromHeight(kToolbarHeight),
                  )
                : null,
      ),
      drawer: release == null ? const AppDrawer() : null,
      body: ProductList(
        release: release,
      ),
    );
  }
}
