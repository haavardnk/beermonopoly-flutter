import 'package:beermonopoly/widgets/stock_change/stock_change_store_select.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/stock_change/stock_change_list_view.dart';
import '../providers/filter.dart';

class StoreStockChangeTab extends StatefulWidget {
  const StoreStockChangeTab({Key? key}) : super(key: key);

  @override
  State<StoreStockChangeTab> createState() => _StoreStockChangeTabState();
}

class _StoreStockChangeTabState extends State<StoreStockChangeTab> {
  @override
  Widget build(BuildContext context) {
    late Filter filters = Provider.of<Filter>(context, listen: false);
    final _openDropDownProgKey = GlobalKey<DropdownSearchState<String>>();

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Consumer<Filter>(
          builder: (context, filter, _) => FittedBox(
            fit: BoxFit.contain,
            child: Text(filters.stockChangeStoreId.isNotEmpty
                ? filter.stockChangeSelectedStore
                : 'Lagerendringer'),
          ),
        ),
        actions: [
          StockChangeStoreSelect(
            openDropDownProgKey: _openDropDownProgKey,
            filters: filters,
          ),
          IconButton(
            onPressed: () {
              _openDropDownProgKey.currentState?.openDropDownSearch();
            },
            icon: Icon(
              Icons.store,
              semanticLabel: "Velg butikk",
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer<Filter>(
        builder: (context, _, __) {
          return filters.stockChangeStoreId.isNotEmpty
              ? StockChangeListView()
              : Center(
                  child: FilledButton.tonalIcon(
                    label: Text('Velg butikk'),
                    icon: Icon(Icons.store),
                    onPressed: () {
                      _openDropDownProgKey.currentState?.openDropDownSearch();
                    },
                  ),
                );
        },
      ),
    );
  }
}
