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
          storeSelect(_openDropDownProgKey, filters),
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

  Visibility storeSelect(
      GlobalKey<DropdownSearchState<String>> _openDropDownProgKey,
      Filter filters) {
    return Visibility(
      maintainState: true,
      visible: false,
      child: Container(
        width: 10,
        child: DropdownSearch<String>(
          key: _openDropDownProgKey,
          popupProps: PopupPropsMultiSelection.dialog(
            showSelectedItems: true,
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                labelText: 'Søk',
                prefixIcon: Icon(
                  Icons.search,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            itemBuilder: (context, item, isSelected) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: ListTile(
                  title: Text(item),
                  subtitle: Text(filters.storeList.isNotEmpty &&
                          filters.storeList
                                  .firstWhere((element) => element.name == item)
                                  .distance !=
                              null
                      ? '${filters.storeList.firstWhere((element) => element.name == item).distance!.toStringAsFixed(0)}km'
                      : ''),
                ),
              );
            },
            containerBuilder: (context, popupWidget) {
              return Column(
                children: [
                  Consumer<Filter>(
                    builder: (context, _, __) {
                      return SwitchListTile(
                        contentPadding: EdgeInsets.only(left: 12, right: 4),
                        title: Text(
                          'Husk valgt butikk',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        value: filters.filterSaveSettings[13]['save'],
                        onChanged: (bool newValue) {
                          filters.filterSaveSettings[13]['save'] = newValue;
                          filters.saveFilterSettings();
                        },
                      );
                    },
                  ),
                  Expanded(child: popupWidget),
                ],
              );
            },
          ),
          items: filters.storeList.map((e) => e.name).toList(),
          onChanged: (String? x) {
            filters.stockChangeSelectedStore = x!;
            filters.setStore(stock: true);
          },
          selectedItem: filters.stockChangeSelectedStore,
        ),
      ),
    );
  }
}
