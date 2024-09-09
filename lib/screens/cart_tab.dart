import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../widgets/cart/cart_element.dart';
import '../widgets/cart/cart_bottom_store_sheet.dart';
import '../widgets/drawer/app_drawer.dart';

class CartTab extends StatelessWidget {
  const CartTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MediaQueryData _mediaQueryData = MediaQuery.of(context);
    final cartData = Provider.of<Cart>(context);
    final _tabletMode = _mediaQueryData.size.width >= 600 ? true : false;
    final double _boxImageSize = _tabletMode
        ? 100 + _mediaQueryData.textScaleFactor * 10
        : _mediaQueryData.size.shortestSide / 4;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            'Handleliste',
          ),
        ),
        actions: [
          const CartBottomStoreSheet(),
        ],
      ),
      drawer: const AppDrawer(),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Expanded(
              child: cartData.itemCount > 0
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Container(
                          child: Column(
                            children: List.generate(
                              cartData.itemCount,
                              (index) {
                                return Column(
                                  children: [
                                    if (index != 0)
                                      Divider(
                                        height: 1,
                                      ),
                                    CartElement(
                                      index,
                                      _boxImageSize,
                                      cartData.items.values.elementAt(index),
                                      cartData,
                                    ),
                                    if (index == cartData.itemCount - 1 &&
                                        cartData.hideNoStock &&
                                        cartData.cartStoreId.isNotEmpty &&
                                        (cartData.itemsInStock.length !=
                                            cartData.itemCount))
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text(
                                              '${cartData.itemCount - cartData.itemsInStock.length} skjulte produkter'),
                                        ),
                                      )
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text('Handelisten er tom'),
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  _createTotalPrice(cartData),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createTotalPrice(Cart cartData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Totalt',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(
              'Kr ${cartData.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        FilledButton.tonalIcon(
          onPressed: () {
            cartData.clear();
          },
          label: Text('Tøm'),
          icon: Icon(Icons.delete_sweep_outlined),
        )
      ],
    );
  }
}
