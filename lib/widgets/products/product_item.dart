import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'package:flag/flag.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../../models/product.dart';
import '../../providers/cart.dart';
import '../../providers/auth.dart';
import '../../screens/product_detail_screen.dart';
import '../rating_widget.dart';
import '../item_popup_menu.dart';
import '../../assets/constants.dart';

class ProductItem extends StatefulWidget {
  const ProductItem({required this.product, Key? key}) : super(key: key);

  final Product product;

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  late bool wishlisted;
  @override
  void initState() {
    wishlisted = widget.product.userWishlisted ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final MediaQueryData _mediaQueryData = MediaQuery.of(context);
    final _tabletMode = _mediaQueryData.size.shortestSide >= 600 ? true : false;
    final cart = Provider.of<Cart>(context, listen: false);
    final countries = countryList;
    final double _boxImageSize = _tabletMode
        ? 100 + _mediaQueryData.textScaleFactor * 10
        : _mediaQueryData.size.shortestSide / 4;
    late Offset tapPosition;
    RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    void getPosition(TapDownDetails detail) {
      tapPosition = detail.globalPosition;
    }

    return Container(
      foregroundDecoration: wishlisted == true
          ? const RotatedCornerDecoration(
              color: Color(0xff01aed6),
              geometry: BadgeGeometry(
                width: 25,
                height: 25,
                cornerRadius: 0,
                alignment: BadgeAlignment.topRight,
              ),
            )
          : null,
      child: Container(
        foregroundDecoration: widget.product.userRating != null
            ? const RotatedCornerDecoration(
                color: Color(0xFFFBC02D),
                geometry: BadgeGeometry(
                  width: 25,
                  height: 25,
                  cornerRadius: 0,
                  alignment: BadgeAlignment.topLeft,
                ),
              )
            : null,
        child: Stack(
          children: [
            Semantics(
              label: widget.product.name,
              button: true,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                    context,
                    settings: RouteSettings(
                        name: ProductDetailScreen.routeName,
                        arguments: <String, dynamic>{
                          'product': widget.product,
                          'herotag': 'list${widget.product.id}'
                        }),
                    screen: ProductDetailScreen(),
                    withNavBar: true,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
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
                    widget.product,
                  ).then(
                    (value) => setState(() {
                      if (value == 'wishlistAdded') {
                        wishlisted = true;
                        cart.updateCartItemsData();
                      }
                      if (value == 'wishlistRemoved') {
                        wishlisted = false;
                        cart.updateCartItemsData();
                      }
                    }),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 6, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          child: Stack(
                            children: [
                              Hero(
                                tag: 'list${widget.product.id}',
                                child: widget.product.imageUrl != null &&
                                        widget.product.imageUrl!.isNotEmpty
                                    ? FancyShimmerImage(
                                        imageUrl: widget.product.imageUrl!,
                                        height: _boxImageSize,
                                        width: _boxImageSize,
                                        errorWidget: Image.asset(
                                          'assets/images/placeholder.png',
                                          height: _boxImageSize,
                                          width: _boxImageSize,
                                        ),
                                      )
                                    : Image.asset(
                                        'assets/images/placeholder.png',
                                        height: _boxImageSize,
                                        width: _boxImageSize,
                                      ),
                              ),
                              if (widget.product.country != null &&
                                  countries[widget.product.country] != null &&
                                  countries[widget.product.country]!.isNotEmpty)
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                      bottomRight: Radius.circular(5)),
                                  child: Flag.fromString(
                                    countries[widget.product.country!]!,
                                    height: 20,
                                    width: 20 * 4 / 3,
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Container(
                              child: Row(
                                children: [
                                  Text(
                                    'Kr ${widget.product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    ' - Kr ${widget.product.pricePerVolume!.toStringAsFixed(2)} pr. liter',
                                    style: const TextStyle(
                                      fontSize: 11,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              child: Text(
                                widget.product.style,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Container(
                              child: widget.product.userRating == null
                                  ? Row(
                                      children: [
                                        Text(
                                          widget.product.rating != null
                                              ? '${widget.product.rating!.toStringAsFixed(2)} '
                                              : '0 ',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                        createRatingBar(
                                            rating:
                                                widget.product.rating != null
                                                    ? widget.product.rating!
                                                    : 0,
                                            size: 18,
                                            color: Colors.yellow[700]!),
                                        Text(
                                          widget.product.checkins != null
                                              ? ' ${NumberFormat.compact().format(widget.product.checkins)}'
                                              : '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Text(
                                          widget.product.rating != null
                                              ? 'Global: ${widget.product.rating!.toStringAsFixed(2)}'
                                              : '0 ',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.yellow[700],
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          widget.product.userRating != null
                                              ? 'Din: ${widget.product.userRating!.toStringAsFixed(2)} '
                                              : '0 ',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.yellow[700],
                                          size: 18,
                                        ),
                                      ],
                                    ),
                            ),
                            Container(
                              height: 11,
                              margin: const EdgeInsets.only(top: 2),
                              child: Row(
                                children: [
                                  if (widget.product.stock != null &&
                                      widget.product.stock != 0)
                                    Row(
                                      children: [
                                        Text(
                                          'På lager: ${widget.product.stock}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            height: 0.9,
                                          ),
                                        ),
                                        VerticalDivider(
                                          width: 15,
                                          thickness: 1,
                                          color: Colors.grey[300],
                                        ),
                                      ],
                                    ),
                                  Row(
                                    children: [
                                      Text(
                                        widget.product.abv != null
                                            ? '${widget.product.abv!.toStringAsFixed(1)}%'
                                            : '',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          height: 0.9,
                                        ),
                                      ),
                                      if (widget.product.abv != null)
                                        VerticalDivider(
                                          width: 15,
                                          thickness: 1,
                                          color: Colors.grey[300],
                                        ),
                                      Text(
                                        '${widget.product.volume}l',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          height: 0.9,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: _tabletMode ? null : 10,
              top: !_tabletMode ? null : _boxImageSize + 11 - 35,
              right: 12,
              child: Semantics(
                button: true,
                label: 'Legg i handleliste',
                child: InkWell(
                  onTap: () {
                    cart.addItem(widget.product.id, widget.product);
                    cart.updateCartItemsData();
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Lagt til i handlelisten!',
                          textAlign: TextAlign.center,
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  onLongPress: () {
                    if (cart.items.keys.contains(widget.product.id)) {
                      cart.removeSingleItem(widget.product.id);
                      cart.updateCartItemsData();
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            cart.items.keys.contains(widget.product.id)
                                ? 'Fjernet en fra handlelisten!'
                                : 'Fjernet helt fra handlelisten!',
                            textAlign: TextAlign.center,
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 35,
                    width: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Consumer<Cart>(
                      builder: (_, cart, __) => Center(
                        child: Badge(
                          isLabelVisible:
                              cart.items.keys.contains(widget.product.id),
                          label: Text(
                              cart.items.keys.contains(widget.product.id)
                                  ? cart.items[widget.product.id]!.quantity
                                      .toString()
                                  : ''),
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            size: 20,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
