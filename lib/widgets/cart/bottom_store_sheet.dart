import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../../providers/cart.dart';
import '../../providers/filter.dart';

class BottomStoreSheet extends StatefulWidget {
  const BottomStoreSheet({Key? key}) : super(key: key);

  @override
  _BottomStoreSheetState createState() => _BottomStoreSheetState();
}

class _BottomStoreSheetState extends State<BottomStoreSheet> {
  Future<void> initCartSettings() async {
    final cart = Provider.of<Cart>(context, listen: false);
    final filters = Provider.of<Filter>(context, listen: false);
    if (cart.useOverviewStoreSelection == true) {
      cart.cartStoreId = filters.storeId;
      cart.cartSelectedStores = filters.selectedStores.toList();
    }
    if (cart.cartStoreId.isNotEmpty && (cart.greyNoStock || cart.hideNoStock)) {
      cart.checkCartStockStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet<void>(
          isScrollControlled: true,
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          builder: (BuildContext context) {
            return _showPopup();
          },
        );
      },
      icon: Icon(
        Icons.settings,
        semanticLabel: "Instillinger",
      ),
    );
  }

  Widget _showPopup() {
    final cart = Provider.of<Cart>(context, listen: false);
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter mystate) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[500],
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    const Text('Butikkvalg for handleliste',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SwitchListTile(
                      contentPadding: EdgeInsets.only(left: 16, right: 4),
                      title: Text(
                          'Grå ut dersom ingen på lager i valgte butikker'),
                      value: cart.greyNoStock,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (bool value) {
                        mystate(() {
                          cart.greyNoStock = value;
                          cart.saveCartSettings();
                          initCartSettings();
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.only(left: 16, right: 4),
                      title:
                          Text('Skjul dersom ingen på lager i valgte butikker'),
                      value: cart.hideNoStock,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (bool value) {
                        mystate(() {
                          cart.hideNoStock = value;
                          cart.saveCartSettings();
                          initCartSettings();
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.only(left: 16, right: 4),
                      title: Text('Bruk butikkvalg fra oversikt'),
                      value: cart.useOverviewStoreSelection,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (bool value) {
                        mystate(() {
                          cart.useOverviewStoreSelection = value;
                          cart.saveCartSettings();
                          initCartSettings();
                        });
                      },
                    ),
                    if (!cart.useOverviewStoreSelection)
                      FadeIn(
                        duration: Duration(milliseconds: 300),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            const Text('Butikk',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Consumer<Filter>(
                              builder: (context, filters, _) {
                                if (!filters.storesLoading &&
                                    filters.storeList.isEmpty) {
                                  filters.getStores();
                                }
                                return filters.storeList.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 8, 0, 8),
                                        child: DropdownSearch<
                                            String>.multiSelection(
                                          popupProps:
                                              PopupPropsMultiSelection.dialog(
                                            showSelectedItems: true,
                                            showSearchBox: true,
                                            searchFieldProps: TextFieldProps(
                                              decoration: InputDecoration(
                                                labelText: 'Søk',
                                                prefixIcon: Icon(Icons.search),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            itemBuilder:
                                                (context, item, isSelected) {
                                              return Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                child: ListTile(
                                                  title: Text(item),
                                                  subtitle: Text(filters
                                                          .storeList.isNotEmpty
                                                      ? '${filters.storeList.firstWhere((element) => element.name == item).distance!.toStringAsFixed(0)}km'
                                                      : ''),
                                                ),
                                              );
                                            },
                                          ),
                                          dropdownBuilder:
                                              (context, selectedItems) {
                                            return Text(
                                              cart.cartSelectedStores.isNotEmpty
                                                  ? cart.cartSelectedStores
                                                      .reduce((a, b) =>
                                                          a + ', ' + b)
                                                  : 'Velg butikker',
                                              style: TextStyle(fontSize: 16),
                                            );
                                          },
                                          dropdownDecoratorProps:
                                              DropDownDecoratorProps(
                                            dropdownSearchDecoration:
                                                InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  10,
                                                ),
                                              ),
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                vertical: 23,
                                                horizontal: 10,
                                              ),
                                            ),
                                          ),
                                          items: filters.storeList
                                              .map((e) => e.name)
                                              .toList(),
                                          onChanged: (List<String> x) {
                                            mystate(() {
                                              cart.cartSelectedStores = x;
                                              cart.setCartStore(
                                                  filters.storeList);
                                              initCartSettings();
                                            });
                                          },
                                          selectedItems:
                                              cart.cartSelectedStores,
                                        ),
                                      )
                                    : Center(
                                        child: CircularProgressIndicator(),
                                      );
                              },
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
