import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flag/flag.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../../providers/cart.dart';
import '../../providers/auth.dart';
import '../../providers/filter.dart';
import '../../providers/http_client.dart';
import '../../helpers/api_helper.dart';
import '../common/rating_widget.dart';
import '../common/item_popup_menu.dart';
import '../../assets/constants.dart';
import '../../screens/product_detail_screen.dart';

class CartElement extends StatefulWidget {
  final int index;
  final double boxImageSize;
  final CartItem cartItem;
  final Cart cartData;

  const CartElement(this.index, this.boxImageSize, this.cartItem, this.cartData,
      {Key? key})
      : super(key: key);

  @override
  _CartElementState createState() => _CartElementState();
}

class _CartElementState extends State<CartElement> {
  bool _expanded = false;
  late bool wishlisted;

  List<dynamic> _stockList = [];
  List<dynamic> _sortStockList(var stockList, var snapshot, var storeList) {
    stockList = snapshot.data!['all_stock'];
    Map<String, int> order = new Map.fromIterable(
      storeList.map((e) => e.name).toList(),
      key: (key) => key,
      value: (key) => storeList.map((e) => e.name).toList().indexOf(key),
    );
    stockList.sort(
        (a, b) => order[a['store_name']]!.compareTo(order[b['store_name']]!));
    return stockList;
  }

  @override
  void initState() {
    wishlisted = widget.cartItem.product.userWishlisted ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const fields = "all_stock";
    final auth = Provider.of<Auth>(context, listen: false);
    final filters = Provider.of<Filter>(context, listen: false);
    final client = Provider.of<HttpClient>(context, listen: false).apiClient;
    final heroTag = 'cart${widget.cartItem.product.id}';
    int quantity = widget.cartItem.quantity;
    late Offset tapPosition;
    RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    void getPosition(TapDownDetails detail) {
      tapPosition = detail.globalPosition;
    }

    return !widget.cartItem.inStock &&
            widget.cartData.hideNoStock &&
            widget.cartData.cartStoreId.isNotEmpty
        ? Wrap()
        : Dismissible(
            key: Key(widget.cartItem.product.id.toString()),
            direction: DismissDirection.startToEnd,
            confirmDismiss: (direction) async {
              final countBefore = widget.cartData.itemCount;
              await showPopupDelete(widget.index, widget.boxImageSize,
                  widget.cartItem, widget.cartData, context);
              final countAfter = widget.cartData.itemCount;
              if (countBefore == countAfter) {
                return false;
              } else {
                return true;
              }
            },
            background: Container(
              color: Colors.pink,
              padding: EdgeInsets.only(left: 50),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.delete,
                  )
                ],
              ),
            ),
            child: Semantics(
              label: widget.cartItem.product.name,
              button: true,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  pushScreen(
                    context,
                    settings: RouteSettings(
                      name: ProductDetailScreen.routeName,
                      arguments: <String, dynamic>{
                        'product': widget.cartItem.product,
                        'herotag': heroTag
                      },
                    ),
                    screen: ProductDetailScreen(),
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                    withNavBar: true,
                  );
                },
                onTapDown: getPosition,
                onLongPress: () {
                  showPopupMenu(
                    context,
                    auth,
                    wishlisted,
                    tapPosition,
                    overlay,
                    widget.cartItem.product,
                  ).then(
                    (value) => setState(
                      () {
                        if (value == 'wishlistAdded') {
                          wishlisted = true;
                          widget.cartData.updateCartItemsData();
                        }
                        if (value == 'wishlistRemoved') {
                          wishlisted = false;
                          widget.cartData.updateCartItemsData();
                        }
                      },
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.fastOutSlowIn,
                  height: _expanded == true
                      ? widget.boxImageSize +
                          110 +
                          MediaQuery.of(context).textScaleFactor * 10
                      : widget.boxImageSize + 24,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Opacity(
                            opacity: !widget.cartItem.inStock &&
                                    widget.cartData.greyNoStock &&
                                    widget.cartData.cartStoreId.isNotEmpty
                                ? 0.3
                                : 1,
                            child: Container(
                              foregroundDecoration: wishlisted == true
                                  ? const RotatedCornerDecoration.withColor(
                                      color: Color(0xff01aed6),
                                      badgeSize: Size(25, 25),
                                      badgePosition: BadgePosition.topEnd,
                                    )
                                  : null,
                              child: Container(
                                foregroundDecoration: widget
                                            .cartItem.product.userRating !=
                                        null
                                    ? const RotatedCornerDecoration.withColor(
                                        color: Color(0xFFFBC02D),
                                        badgeSize: Size(25, 25),
                                        badgePosition: BadgePosition.topStart,
                                      )
                                    : null,
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(6)),
                                      child: Stack(
                                        children: [
                                          Hero(
                                            tag: heroTag,
                                            child: widget.cartItem.product
                                                        .imageUrl !=
                                                    null
                                                ? FancyShimmerImage(
                                                    imageUrl: widget.cartItem
                                                        .product.imageUrl!,
                                                    height: widget.boxImageSize,
                                                    width: widget.boxImageSize,
                                                    errorWidget: Image.asset(
                                                      'assets/images/placeholder.png',
                                                      height:
                                                          widget.boxImageSize,
                                                      width:
                                                          widget.boxImageSize,
                                                    ),
                                                  )
                                                : Image.asset(
                                                    'assets/images/placeholder.png',
                                                    height: widget.boxImageSize,
                                                    width: widget.boxImageSize,
                                                  ),
                                          ),
                                          if (widget.cartItem.product
                                                      .country !=
                                                  null &&
                                              countryList[widget.cartItem
                                                      .product.country] !=
                                                  null &&
                                              countryList[widget.cartItem
                                                      .product.country]!
                                                  .isNotEmpty)
                                            ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      bottomRight:
                                                          Radius.circular(6)),
                                              child: Flag.fromString(
                                                countryList[widget.cartItem
                                                    .product.country!]!,
                                                height: 20,
                                                width: 20 * 4 / 3,
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.cartItem.product.name,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(top: 5),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'Kr ${widget.cartItem.product.price.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  if (widget.cartItem.product
                                                          .pricePerVolume !=
                                                      null)
                                                    Expanded(
                                                      child: Text(
                                                        ' - Kr ${widget.cartItem.product.pricePerVolume!.toStringAsFixed(2)} pr. liter',
                                                        style: const TextStyle(
                                                            fontSize: 11,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis),
                                                      ),
                                                    )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(top: 5),
                                              child: widget.cartItem.product
                                                          .userRating ==
                                                      null
                                                  ? Row(
                                                      children: [
                                                        Text(
                                                          widget
                                                                      .cartItem
                                                                      .product
                                                                      .rating !=
                                                                  null
                                                              ? '${widget.cartItem.product.rating!.toStringAsFixed(2)} '
                                                              : '0 ',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        createRatingBar(
                                                            rating: widget
                                                                        .cartItem
                                                                        .product
                                                                        .rating !=
                                                                    null
                                                                ? widget
                                                                    .cartItem
                                                                    .product
                                                                    .rating!
                                                                : 0,
                                                            size: 18,
                                                            color: Colors
                                                                .yellow[700]!),
                                                        Text(
                                                          widget
                                                                      .cartItem
                                                                      .product
                                                                      .checkins !=
                                                                  null
                                                              ? ' ${NumberFormat.compact().format(widget.cartItem.product.checkins)}'
                                                              : '',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Row(
                                                      children: [
                                                        Text(
                                                          widget
                                                                      .cartItem
                                                                      .product
                                                                      .rating !=
                                                                  null
                                                              ? 'Global: ${widget.cartItem.product.rating!.toStringAsFixed(2)}'
                                                              : '0 ',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons.star,
                                                          color: Colors
                                                              .yellow[700],
                                                          size: 18,
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(
                                                          widget
                                                                      .cartItem
                                                                      .product
                                                                      .userRating !=
                                                                  null
                                                              ? 'Din: ${widget.cartItem.product.userRating!.toStringAsFixed(2)} '
                                                              : '0 ',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons.star,
                                                          color: Colors
                                                              .yellow[700],
                                                          size: 18,
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          height: widget.boxImageSize - 31,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 1,
                                              color: Colors.grey[400]!,
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(24),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Semantics(
                                                      label: 'Legg til en',
                                                      button: true,
                                                      child: InkWell(
                                                        onTap: () {
                                                          widget.cartData
                                                              .addItem(
                                                            widget.cartItem
                                                                .product.id,
                                                            widget.cartItem
                                                                .product,
                                                          );
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  10, 0, 10, 2),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(
                                                              Radius.circular(
                                                                  5),
                                                            ),
                                                          ),
                                                          child: Icon(
                                                            Icons.add,
                                                            size: 18,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onBackground,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Semantics(
                                                      label: 'Fjern en',
                                                      button: true,
                                                      child: InkWell(
                                                        onTap: () {
                                                          quantity == 1
                                                              ? showPopupDelete(
                                                                  widget.index,
                                                                  widget
                                                                      .boxImageSize,
                                                                  widget
                                                                      .cartItem,
                                                                  widget
                                                                      .cartData,
                                                                  context)
                                                              : widget.cartData
                                                                  .removeSingleItem(
                                                                      widget
                                                                          .cartItem
                                                                          .product
                                                                          .id);
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  10, 2, 10, 0),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(
                                                              Radius.circular(
                                                                  5),
                                                            ),
                                                          ),
                                                          child: Icon(
                                                            Icons.remove,
                                                            size: 18,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onBackground,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Center(
                                                child: Text(
                                                  quantity.toString(),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Semantics(
                                          label:
                                              'Vis butikker med varen på lager',
                                          button: true,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                _expanded = !_expanded;
                                              });
                                            },
                                            child: Container(
                                              height: 28,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: 1,
                                                  color: Colors.grey[400]!,
                                                ),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(24),
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.store_outlined,
                                                size: 17,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (_expanded == true)
                            FutureBuilder(
                              future: ApiHelper.getDetailedProductInfo(client,
                                  widget.cartItem.product.id, auth, fields),
                              builder: (context,
                                  AsyncSnapshot<Map<String, dynamic>>
                                      snapshot) {
                                if (snapshot.hasData &&
                                    snapshot.data!['all_stock'] != null &&
                                    filters.storeList.isNotEmpty) {
                                  _stockList = _sortStockList(
                                      _stockList, snapshot, filters.storeList);
                                }
                                return Expanded(
                                  child: snapshot.connectionState ==
                                          ConnectionState.waiting
                                      ? FadeIn(
                                          duration: Duration(milliseconds: 500),
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              12, 0, 12, 12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (_stockList.isNotEmpty)
                                                Expanded(
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        _stockList.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Column(
                                                        children: [
                                                          FadeIn(
                                                            duration: Duration(
                                                                milliseconds:
                                                                    300),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  _stockList[
                                                                          index]
                                                                      [
                                                                      'store_name'],
                                                                ),
                                                                Text(
                                                                  'På lager: ${_stockList[index]['quantity']}',
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Divider(height: 5),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                              if (_stockList.isEmpty)
                                                Expanded(
                                                  child: Center(
                                                    child: FadeIn(
                                                      duration: Duration(
                                                          milliseconds: 300),
                                                      child: Text(
                                                        'Ingen butikker har denne på lager',
                                                      ),
                                                    ),
                                                  ),
                                                )
                                            ],
                                          ),
                                        ),
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}

Future<void> showPopupDelete(int index, double boxImageSize, CartItem cartItem,
    Cart cartData, BuildContext context) async {
  Widget cancelButton = FilledButton.tonal(
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop();
    },
    child: const Text('Nei'),
  );
  Widget continueButton = FilledButton.tonal(
    onPressed: () {
      cartData.removeItem(cartItem.product.id);
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80.0),
          content: Text(
            'Produktet har blitt fjernet fra handlelisten din.',
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
        ),
      );
    },
    child: const Text('Ja'),
  );

  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    title: const Text(
      'Fjern fra handleliste',
      style: TextStyle(fontSize: 18),
    ),
    content: const Text(
      'Er du sikker på at du vil fjerne dette produktet fra handlelisten?',
      style: TextStyle(
        fontSize: 13,
      ),
    ),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
