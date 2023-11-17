import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/filter.dart';

class StockChangeStoreSelect extends StatelessWidget {
  const StockChangeStoreSelect({
    Key? key,
    required GlobalKey<DropdownSearchState<String>> openDropDownProgKey,
    required this.filters,
  })  : _openDropDownProgKey = openDropDownProgKey,
        super(key: key);

  final GlobalKey<DropdownSearchState<String>> _openDropDownProgKey;
  final Filter filters;

  @override
  Widget build(BuildContext context) {
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
