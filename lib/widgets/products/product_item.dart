import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'package:flag/flag.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../common/item_popup_menu.dart';
import '../../models/product.dart';
import '../../models/release.dart';
import '../../providers/cart.dart';
import '../../providers/auth.dart';
import '../../screens/product_detail_screen.dart';
import '../common/rating_widget.dart';
import '../../assets/constants.dart';

class ProductItem extends StatefulWidget {
  const ProductItem({required this.product, Key? key, this.release})
      : super(key: key);

  final Product product;
  final Release? release;

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  late bool wishlisted;
  late bool tasted;
  GlobalKey actionsKey = GlobalKey();
  @override
  void initState() {
    wishlisted = widget.product.userWishlisted ?? false;
    tasted = widget.product.userTasted ?? false;
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
    final heroTag = widget.release != null
        ? 'release${widget.product.id}'
        : 'products${widget.product.id}';

    return Container(
      foregroundDecoration: wishlisted == true
          ? const RotatedCornerDecoration.withColor(
              color: Color(0xff01aed6),
              badgeSize: Size(25, 25),
              badgePosition: BadgePosition.topEnd,
            )
          : null,
      child: Container(
        foregroundDecoration:
            widget.product.userRating != null || tasted == true
                ? const RotatedCornerDecoration.withColor(
                    color: Color(0xFFFBC02D),
                    badgeSize: Size(25, 25),
                    badgePosition: BadgePosition.topStart,
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
                  pushScreen(
                    context,
                    settings: RouteSettings(
                        name: ProductDetailScreen.routeName,
                        arguments: <String, dynamic>{
                          'product': widget.product,
                          'herotag': heroTag
                        }),
                    screen: ProductDetailScreen(),
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                    withNavBar: true,
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
                              const BorderRadius.all(Radius.circular(6)),
                          child: Stack(
                            children: [
                              Hero(
                                tag: heroTag,
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
                                      bottomRight: Radius.circular(6)),
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
                                      if (widget.release != null &&
                                          widget.release!.productSelections
                                                  .length >
                                              1)
                                        VerticalDivider(
                                          width: 15,
                                          thickness: 1,
                                          color: Colors.grey[300],
                                        ),
                                      if (widget.release != null &&
                                          widget.release!.productSelections
                                                  .length >
                                              1)
                                        Text(
                                          '${productSelectionAbrevationList[widget.product.product_selection]}',
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
              child: IconButton(
                key: actionsKey,
                icon: Icon(Icons.more_horiz),
                iconSize: 28,
                onPressed: () {
                  RenderBox renderBox = actionsKey.currentContext!
                      .findRenderObject() as RenderBox;
                  Offset offset = renderBox.localToGlobal(Offset.zero);
                  showPopupMenu(
                    context,
                    auth,
                    tasted,
                    RelativeRect.fromLTRB(
                      offset.dx,
                      offset.dy,
                      offset.dx,
                      offset.dy,
                    ),
                    widget.product,
                  ).then(
                    (value) => setState(() {
                      if (value == 'addedTasted') {
                        tasted = true;
                        cart.updateCartItemsData();
                      }
                      if (value == 'removedTasted') {
                        tasted = false;
                        cart.updateCartItemsData();
                      }
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
