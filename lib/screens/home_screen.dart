import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

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

    List<PersistentBottomNavBarItem> _navBarItems = [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.liquor),
        activeColorSecondary:
            Theme.of(context).colorScheme.onSecondaryContainer,
        inactiveColorPrimary: Theme.of(context).colorScheme.onSurfaceVariant,
        inactiveColorSecondary: Theme.of(context).colorScheme.onSurfaceVariant,
        title: 'Produkter',
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.new_releases_outlined),
        activeColorSecondary:
            Theme.of(context).colorScheme.onSecondaryContainer,
        inactiveColorPrimary: Theme.of(context).colorScheme.onSurfaceVariant,
        inactiveColorSecondary: Theme.of(context).colorScheme.onSurfaceVariant,
        title: 'Lanseringer',
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.swap_vert),
        activeColorSecondary:
            Theme.of(context).colorScheme.onSecondaryContainer,
        inactiveColorPrimary: Theme.of(context).colorScheme.onSurfaceVariant,
        inactiveColorSecondary: Theme.of(context).colorScheme.onSurfaceVariant,
        title: 'Lager inn/ut',
      ),
      PersistentBottomNavBarItem(
        icon: Consumer<Cart>(
          builder: (_, cart, __) => Badge(
            label: Text(cart.itemCount.toString()),
            child: Icon(Icons.receipt_long),
            isLabelVisible: cart.itemCount > 0,
          ),
        ),
        activeColorSecondary:
            Theme.of(context).colorScheme.onSecondaryContainer,
        inactiveColorPrimary: Theme.of(context).colorScheme.onSurfaceVariant,
        inactiveColorSecondary: Theme.of(context).colorScheme.onSurfaceVariant,
        title: 'Handleliste',
      )
    ];

    List<Widget> _buildScreens = const [
      ProductOverviewTab(),
      ReleaseTab(),
      StoreStockChangeTab(),
      CartTab(),
    ];

    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens,
      items: _navBarItems,
      resizeToAvoidBottomInset: true,
      confineInSafeArea: true,
      backgroundColor: Theme.of(context).canvasColor,

      itemAnimationProperties: const ItemAnimationProperties(
        duration: Duration(milliseconds: 400),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation(
        animateTabTransition: true,
      ),
      navBarStyle:
          NavBarStyle.style6, // Choose the nav bar style with this property
    );
  }
}
