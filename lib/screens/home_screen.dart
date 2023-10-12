import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import 'product_overview_tab.dart';
import 'release_tab.dart';
import 'store_stock_change_tab.dart';
import 'cart_tab.dart';
import '../providers/filter.dart';
import '../providers/cart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const routeName = '/tabs';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PersistentTabController _controller = PersistentTabController();

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

    List<PersistentTabConfig> _tabs = [
      PersistentTabConfig(
        screen: ProductOverviewTab(),
        item: ItemConfig(
          icon: Icon(Icons.liquor),
          activeColorPrimary:
              Theme.of(context).colorScheme.onSecondaryContainer,
          inactiveColorPrimary: Theme.of(context).colorScheme.onSurfaceVariant,
          inactiveColorSecondary:
              Theme.of(context).colorScheme.onSurfaceVariant,
          title: 'Produkter',
        ),
      ),
      PersistentTabConfig(
        screen: ReleaseTab(),
        item: ItemConfig(
          icon: Icon(Icons.new_releases_outlined),
          activeColorPrimary:
              Theme.of(context).colorScheme.onSecondaryContainer,
          inactiveColorPrimary: Theme.of(context).colorScheme.onSurfaceVariant,
          inactiveColorSecondary:
              Theme.of(context).colorScheme.onSurfaceVariant,
          title: 'Lanseringer',
        ),
      ),
      PersistentTabConfig(
        screen: StoreStockChangeTab(),
        item: ItemConfig(
          icon: Icon(Icons.swap_vert),
          activeColorPrimary:
              Theme.of(context).colorScheme.onSecondaryContainer,
          inactiveColorPrimary: Theme.of(context).colorScheme.onSurfaceVariant,
          inactiveColorSecondary:
              Theme.of(context).colorScheme.onSurfaceVariant,
          title: 'Lager inn/ut',
        ),
      ),
      PersistentTabConfig(
        screen: CartTab(),
        item: ItemConfig(
          icon: Consumer<Cart>(
            builder: (_, cart, __) => Badge(
              label: Text(cart.itemCount.toString()),
              child: Icon(Icons.receipt_long),
              isLabelVisible: cart.itemCount > 0,
            ),
          ),
          activeColorPrimary:
              Theme.of(context).colorScheme.onSecondaryContainer,
          inactiveColorPrimary: Theme.of(context).colorScheme.onSurfaceVariant,
          inactiveColorSecondary:
              Theme.of(context).colorScheme.onSurfaceVariant,
          title: 'Handleliste',
        ),
      ),
    ];

    return PersistentTabView(
      controller: _controller,
      tabs: _tabs,
      resizeToAvoidBottomInset: true,
      avoidBottomPadding: true,
      navBarOverlap: NavBarOverlap.none(),
      backgroundColor: Theme.of(context).canvasColor,
      navBarBuilder: (navBarConfig) => Style6BottomNavBar(
        navBarConfig: navBarConfig,
        navBarDecoration: NavBarDecoration(
          color: Theme.of(context).canvasColor,
        ),
      ),
    );
  }
}
