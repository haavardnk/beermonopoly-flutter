import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fadein/flutter_fadein.dart';

import 'product_overview_tab.dart';
import 'cart_tab.dart';
import '../widgets/app_drawer.dart';
import '../widgets/products/bottom_filter_sheet.dart';
import '../widgets/products/search_bar.dart';
import '../widgets/cart/bottom_store_sheet.dart';
import '../providers/filter.dart';
import '../providers/cart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const routeName = '/tabs';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

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
    Provider.of<Cart>(context, listen: false).fetchAndSetCart();
    final filters = Provider.of<Filter>(context, listen: false);
    if (!filters.storesLoading && filters.storeList.isEmpty) {
      filters.getStores();
    }
    if (!filters.releasesLoading && filters.releaseList.isEmpty) {
      filters.getReleases();
    }
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
          if (_currentIndex == 0) const BottomFilterSheet(),
          if (_currentIndex == 1) BottomStoreSheet(initCartSettings),
        ],
        bottom: _currentIndex == 0
            ? const PreferredSize(
                child: SearchBar(),
                preferredSize: Size.fromHeight(kToolbarHeight),
              )
            : null,
      ),
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          ProductOverviewTab(),
          CartTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.liquor),
            label: 'Produkter',
          ),
          BottomNavigationBarItem(
            icon: Consumer<Cart>(
              builder: (_, cart, __) => Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.receipt_long),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        // color: Theme.of(context).accentColor,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.pink,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 11,
                          minHeight: 11,
                        ),
                        child: Text(
                          cart.itemCount.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
            label: 'Handleliste',
          )
        ],
      ),
    );
  }
}
