import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../widgets/cart/cart_element.dart';

class CartTab extends StatefulWidget {
  const CartTab({Key? key}) : super(key: key);

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Widget build(BuildContext context) {
    final MediaQueryData _mediaQueryData = MediaQuery.of(context);
    final cartData = Provider.of<Cart>(context);
    final _tabletMode = _mediaQueryData.size.width >= 600 ? true : false;
    final double _boxImageSize = _tabletMode
        ? 100 + _mediaQueryData.textScaleFactor * 10
        : _mediaQueryData.size.shortestSide / 4;
    super.build(context);
    return Scaffold(
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
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).backgroundColor,
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
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) => Colors.pink,
            ),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            )),
          ),
          onPressed: () {
            cartData.clear();
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'TØM',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    );
  }
}
