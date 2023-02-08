import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fadein/flutter_fadein.dart';

import '../widgets/products/product_list_view.dart';
import '../providers/filter.dart';
import '../widgets/app_drawer.dart';
import '../widgets/products/bottom_filter_sheet.dart';
import '../widgets/products/search_bar.dart';

class ProductOverviewTab extends StatelessWidget {
  const ProductOverviewTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _currentIndex = 0;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        title: Consumer<Filter>(
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
                style: TextStyle(
                    color: Theme.of(context).textTheme.headline6!.color),
              ),
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          ),
        ),
        actions: [
          const BottomFilterSheet(),
        ],
        bottom: const PreferredSize(
          child: SearchBar(),
          preferredSize: Size.fromHeight(kToolbarHeight),
        ),
      ),
      drawer: const AppDrawer(),
      body: const ProductListView(),
    );
  }
}
