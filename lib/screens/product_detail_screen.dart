import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flag/flag.dart';

import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/filter.dart';
import '../helpers/api_helper.dart';
import '../helpers/untappd_helper.dart';
import '../helpers/app_launcher.dart';
import '../models/product.dart';
import '../widgets/common/rating_widget.dart';
import '../../assets/constants.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);
  static const routeName = '/product-detail';
  static final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late bool wishlisted;
  late bool init = false;

  int _numRatings = 0;
  double _friendsRating = 0;
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
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final product = args['product'] as Product;
    final herotag = args['herotag'] as String;
    final auth = Provider.of<Auth>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final filters = Provider.of<Filter>(context, listen: false);
    final countries = countryList;
    final _mediaQueryData = MediaQuery.of(context);
    final _tabletMode = _mediaQueryData.size.width >= 600 ? true : false;
    final _boxImageSize =
        _mediaQueryData.size.shortestSide * (_tabletMode ? 0.4 : 0.75);
    const fields =
        'label_hd_url,ibu,description,brewery,product_selection,all_stock,'
        'year,color,aroma,taste,storable,food_pairing,raw_materials,fullness,'
        'sweetness,freshness,bitterness,sugar,acid,method,allergens,'
        'user_checked_in,friends_checked_in,app_rating,alcohol_units';

    if (init == false) {
      wishlisted = product.userWishlisted ?? false;
      init = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detaljer'),
        surfaceTintColor: Colors.transparent,
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              if (auth.isAuth)
                PopupMenuItem<int>(
                  value: 0,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Row(
                      children: [
                        Icon(!wishlisted
                            ? Icons.playlist_add
                            : Icons.playlist_remove),
                        VerticalDivider(width: 5),
                        Text(!wishlisted
                            ? 'Legg i Untappd ønskeliste'
                            : 'Fjern fra Untappd ønskeliste'),
                      ],
                    ),
                  ),
                ),
              PopupMenuItem<int>(
                value: 1,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Row(
                    children: [
                      Icon(Icons.report),
                      VerticalDivider(width: 5),
                      Text(
                        product.rating != null
                            ? 'Rapporter feil Untappd match'
                            : 'Foreslå untappd match',
                        overflow: TextOverflow.fade,
                      ),
                    ],
                  ),
                ),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Row(
                    children: [
                      Icon(Icons.open_in_browser),
                      VerticalDivider(width: 5),
                      Text("Åpne i Untappd"),
                    ],
                  ),
                ),
              ),
              PopupMenuItem<int>(
                value: 3,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Row(
                    children: [
                      Icon(Icons.open_in_browser),
                      VerticalDivider(width: 5),
                      Text("Åpne i Vinmonopolet"),
                    ],
                  ),
                ),
              ),
            ];
          }, onSelected: (value) {
            if (value == 0) {
              toggleWishlist(auth, product, cart);
            } else if (value == 1) {
              wrongUntappdMatch(product);
            } else if (value == 2) {
              AppLauncher.launchUntappd(product);
            } else if (value == 3) {
              product.vmpUrl != null
                  ? launchUrl(Uri.parse(product.vmpUrl!))
                  : null;
            }
          }),
        ],
      ),
      floatingActionButton: InkWell(
        onLongPress: () {
          if (cart.items.keys.contains(product.id)) {
            cart.removeSingleItem(product.id);
            cart.updateCartItemsData();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  cart.items.keys.contains(product.id)
                      ? 'Fjernet en fra handlelisten!'
                      : 'Fjernet helt fra handlelisten!',
                  textAlign: TextAlign.center,
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
        child: FloatingActionButton(
          child: Consumer<Cart>(
            builder: (context, _, __) => Badge(
              isLabelVisible: cart.items.keys.contains(product.id),
              label: Text(cart.items.keys.contains(product.id)
                  ? cart.items[product.id]!.quantity.toString()
                  : ''),
              child: Icon(Icons.add_shopping_cart),
            ),
          ),
          onPressed: () {
            cart.addItem(product.id, product);
            cart.updateCartItemsData();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Lagt til i handlelisten!',
                  textAlign: TextAlign.center,
                ),
                duration: const Duration(seconds: 1),
                action: SnackBarAction(
                  label: 'ANGRE',
                  onPressed: () {
                    cart.removeSingleItem(product.id);
                  },
                ),
              ),
            );
          },
        ),
      ),
      body: FutureBuilder(
        future:
            ApiHelper.getDetailedProductInfo(product.id, auth.apiToken, fields),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.hasData &&
              snapshot.data!['all_stock'] != null &&
              filters.storeList.isNotEmpty) {
            _stockList =
                _sortStockList(_stockList, snapshot, filters.storeList);
          }
          if (snapshot.hasData) {
            _numRatings = 0;
            _friendsRating = 0;
            if (snapshot.data!['app_rating'] != null &&
                snapshot.data!['app_rating']['rating'] != null) {
              _numRatings += 1;
            }
            if (snapshot.data!['friends_checked_in'] != null &&
                snapshot.data!['friends_checked_in'].isNotEmpty) {
              _numRatings += 1;
              snapshot.data!['friends_checked_in']
                  .forEach((friend) => {_friendsRating += friend['rating']});
              _friendsRating =
                  _friendsRating / snapshot.data!['friends_checked_in'].length;
            }
            if (product.userRating != null) {
              _numRatings += 1;
            }
          }
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: _tabletMode &&
                          _mediaQueryData.orientation == Orientation.landscape
                      ? EdgeInsets.symmetric(
                          horizontal: _mediaQueryData.size.width * 0.15)
                      : null,
                  children: [
                    Container(
                      foregroundDecoration: wishlisted == true
                          ? const RotatedCornerDecoration.withColor(
                              color: Color(0xff01aed6),
                              textSpan: TextSpan(text: 'Ønsket'),
                              badgeSize: Size(60, 60),
                              badgePosition: BadgePosition.topEnd,
                            )
                          : null,
                      child: Container(
                        foregroundDecoration: product.userRating != null
                            ? const RotatedCornerDecoration.withColor(
                                color: Color(0xFFFBC02D),
                                textSpan: TextSpan(text: 'Smakt'),
                                badgeSize: Size(60, 60),
                                badgePosition: BadgePosition.topStart,
                              )
                            : null,
                        height: _boxImageSize,
                        width: _boxImageSize,
                        child: snapshot.hasData &&
                                snapshot.data!['label_hd_url'] != null &&
                                snapshot.data!['label_hd_url'].isNotEmpty
                            ? FadeInImage(
                                fit: BoxFit.contain,
                                image: NetworkImage(
                                  snapshot.data!['label_hd_url'],
                                ),
                                placeholder: product.imageUrl != null
                                    ? NetworkImage(product.imageUrl!)
                                    : Image.asset(
                                        'assets/images/placeholder.png',
                                        fit: BoxFit.contain,
                                      ).image,
                              )
                            : Hero(
                                tag: herotag,
                                child: product.imageUrl != null
                                    ? Image.network(
                                        product.imageUrl!,
                                        fit: BoxFit.contain,
                                      )
                                    : Image.asset(
                                        'assets/images/placeholder.png',
                                        fit: BoxFit.contain,
                                      ),
                              ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: const TextStyle(fontSize: 18),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Kr ${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              if (product.pricePerVolume != null)
                                Text(
                                  ' - Kr ${product.pricePerVolume!.toStringAsFixed(2)} pr. liter',
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                )
                            ],
                          ),
                          Text(
                            product.style,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const Divider(
                            height: 15,
                          ),
                        ],
                      ),
                    ),
                    if (!snapshot.hasData)
                      Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 8,
                          ),
                          Center(
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      ),
                    if (snapshot.hasData)
                      FadeIn(
                        duration: const Duration(milliseconds: 500),
                        child: Column(
                          children: [
                            Column(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (product.rating != null)
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 0, 20, 0),
                                          child: IntrinsicHeight(
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: _tabletMode
                                                      ? MainAxisAlignment
                                                          .spaceEvenly
                                                      : MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    InkWell(
                                                      onTap: () => AppLauncher
                                                          .launchUntappd(
                                                              product),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            'Global rating - ${NumberFormat.compact().format(product.checkins)}',
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        14),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                product.rating !=
                                                                        null
                                                                    ? '${product.rating!.toStringAsFixed(2)} '
                                                                    : '0 ',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                              createRatingBar(
                                                                  rating: product
                                                                              .rating !=
                                                                          null
                                                                      ? product
                                                                          .rating!
                                                                      : 0,
                                                                  size: 18,
                                                                  color: Colors
                                                                          .yellow[
                                                                      700]!),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    if ((_numRatings == 1) &&
                                                        snapshot.hasData &&
                                                        snapshot.data![
                                                                'app_rating'] !=
                                                            null &&
                                                        snapshot.data![
                                                                    'app_rating']
                                                                ['rating'] !=
                                                            null)
                                                      Column(
                                                        children: [
                                                          Text(
                                                            'Ølmonopolet - ${snapshot.data!['app_rating']['count']}',
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        14),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                '${snapshot.data!['app_rating']['rating'].toStringAsFixed(2)} ',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                              createRatingBar(
                                                                  rating: snapshot
                                                                              .data![
                                                                          'app_rating']
                                                                      [
                                                                      'rating'],
                                                                  size: 18,
                                                                  color: Color(
                                                                      0xff01aed6)),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    if (product.userRating !=
                                                        null)
                                                      Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const Text(
                                                                'Din rating',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                              if (snapshot
                                                                      .hasData &&
                                                                  snapshot.data![
                                                                          'user_checked_in'] !=
                                                                      null)
                                                                Text(
                                                                  ' - ${snapshot.data!['user_checked_in'][0]['count']}',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14),
                                                                )
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                product.userRating !=
                                                                        null
                                                                    ? '${product.userRating!.toStringAsFixed(2)} '
                                                                    : '0 ',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                              createRatingBar(
                                                                  rating: product
                                                                              .userRating !=
                                                                          null
                                                                      ? product
                                                                          .userRating!
                                                                      : 0,
                                                                  size: 18,
                                                                  color: Colors
                                                                          .yellow[
                                                                      700]!),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                                if (_numRatings > 1)
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                if (_numRatings > 1)
                                                  Row(
                                                    mainAxisAlignment:
                                                        _tabletMode
                                                            ? MainAxisAlignment
                                                                .spaceEvenly
                                                            : MainAxisAlignment
                                                                .spaceBetween,
                                                    children: [
                                                      if (snapshot.data![
                                                                  'app_rating'] !=
                                                              null &&
                                                          snapshot.data![
                                                                      'app_rating']
                                                                  ['rating'] !=
                                                              null)
                                                        Column(
                                                          children: [
                                                            Text(
                                                              'Ølmonopolet - ${snapshot.data!['app_rating']['count']}',
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14),
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  '${snapshot.data!['app_rating']['rating'].toStringAsFixed(2)} ',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                ),
                                                                createRatingBar(
                                                                    rating: snapshot
                                                                            .data!['app_rating']
                                                                        [
                                                                        'rating'],
                                                                    size: 18,
                                                                    color: Color(
                                                                        0xff01aed6)),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      if (snapshot.data![
                                                                  'friends_checked_in'] !=
                                                              null &&
                                                          snapshot
                                                              .data![
                                                                  'friends_checked_in']
                                                              .isNotEmpty)
                                                        InkWell(
                                                          onTap: () {
                                                            friendsCheckins(
                                                              snapshot.data![
                                                                  'friends_checked_in'],
                                                              _mediaQueryData,
                                                            );
                                                          },
                                                          child: Column(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    'Venner - ${snapshot.data!['friends_checked_in'].length}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    '${_friendsRating.toStringAsFixed(2)} ',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                  ),
                                                                  createRatingBar(
                                                                      rating:
                                                                          _friendsRating,
                                                                      size: 18,
                                                                      color: Color(
                                                                          0xff01aed6)),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      if (product.rating == null)
                                        const Text(
                                          'Ingen Untappd Match',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      if (snapshot.hasData &&
                                          (snapshot.data!['freshness'] !=
                                                  null ||
                                              snapshot.data!['bitterness'] !=
                                                  null ||
                                              snapshot.data!['sweetness'] !=
                                                  null ||
                                              snapshot.data!['fullness'] !=
                                                  null))
                                        const Divider(
                                          height: 20,
                                        ),
                                      if (snapshot.hasData &&
                                          (snapshot.data!['freshness'] !=
                                                  null ||
                                              snapshot.data!['bitterness'] !=
                                                  null ||
                                              snapshot.data!['sweetness'] !=
                                                  null ||
                                              snapshot.data!['fullness'] !=
                                                  null))
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            if (snapshot.data!['freshness'] !=
                                                null)
                                              CircularPercentIndicator(
                                                radius: 25.0,
                                                lineWidth: 5.0,
                                                animation: true,
                                                percent: snapshot
                                                        .data!['freshness']
                                                        .toDouble() /
                                                    12,
                                                center: Text((snapshot.data![
                                                                'freshness'] /
                                                            12 *
                                                            100)
                                                        .toStringAsFixed(0) +
                                                    '%'),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .surfaceVariant,
                                                progressColor: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                circularStrokeCap:
                                                    CircularStrokeCap.round,
                                                footer: const Text(
                                                  "Friskhet",
                                                ),
                                              ),
                                            if (snapshot.data!['fullness'] !=
                                                null)
                                              CircularPercentIndicator(
                                                radius: 25.0,
                                                lineWidth: 5.0,
                                                animation: true,
                                                percent: snapshot
                                                        .data!['fullness']
                                                        .toDouble() /
                                                    12,
                                                center: Text((snapshot.data![
                                                                'fullness'] /
                                                            12 *
                                                            100)
                                                        .toStringAsFixed(0) +
                                                    '%'),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .surfaceVariant,
                                                progressColor: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                circularStrokeCap:
                                                    CircularStrokeCap.round,
                                                footer: const Text(
                                                  "Fylde",
                                                ),
                                              ),
                                            if (snapshot.data!['bitterness'] !=
                                                null)
                                              CircularPercentIndicator(
                                                radius: 25.0,
                                                lineWidth: 5.0,
                                                animation: true,
                                                percent: snapshot
                                                        .data!['bitterness']
                                                        .toDouble() /
                                                    12,
                                                center: Text((snapshot.data![
                                                                'bitterness'] /
                                                            12 *
                                                            100)
                                                        .toStringAsFixed(0) +
                                                    '%'),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .surfaceVariant,
                                                progressColor: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                circularStrokeCap:
                                                    CircularStrokeCap.round,
                                                footer: const Text(
                                                  "Bitterhet",
                                                ),
                                              ),
                                            if (snapshot.data!['sweetness'] !=
                                                    null &&
                                                snapshot.data!['sweetness'] !=
                                                    0)
                                              CircularPercentIndicator(
                                                radius: 25.0,
                                                lineWidth: 5.0,
                                                animation: true,
                                                percent: snapshot
                                                        .data!['sweetness']
                                                        .toDouble() /
                                                    12,
                                                center: Text((snapshot.data![
                                                                'sweetness'] /
                                                            12 *
                                                            100)
                                                        .toStringAsFixed(0) +
                                                    '%'),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .surfaceVariant,
                                                progressColor: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                circularStrokeCap:
                                                    CircularStrokeCap.round,
                                                footer: const Text(
                                                  "Sødme",
                                                ),
                                              )
                                          ],
                                        ),
                                      const Divider(
                                        height: 15,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          if (product.abv != null)
                                            Column(
                                              children: [
                                                const Text('Styrke'),
                                                Text('${product.abv} %'),
                                              ],
                                            ),
                                          Column(
                                            children: [
                                              const Text('Størrelse'),
                                              Text('${product.volume} l'),
                                            ],
                                          ),
                                          if (snapshot.hasData &&
                                              snapshot.data!['acid'] != null)
                                            FadeIn(
                                              child: Column(
                                                children: [
                                                  const Text('Syre'),
                                                  Text(
                                                      '${snapshot.data!['acid']} g/l'),
                                                ],
                                              ),
                                            ),
                                          if (snapshot.hasData &&
                                              snapshot.data!['sugar'] != null)
                                            FadeIn(
                                              child: Column(
                                                children: [
                                                  const Text('Sukker'),
                                                  Text(
                                                      '${snapshot.data!['sugar']} g/l'),
                                                ],
                                              ),
                                            ),
                                          if (snapshot.hasData &&
                                              snapshot.data!['ibu'] != null &&
                                              snapshot.data!['ibu'] != 0)
                                            FadeIn(
                                              child: Column(
                                                children: [
                                                  const Text('IBU'),
                                                  Text(
                                                    snapshot.data!['ibu']
                                                        .toString(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (snapshot.hasData &&
                                              snapshot.data!['alcohol_units'] !=
                                                  null &&
                                              snapshot.data!['alcohol_units'] !=
                                                  0)
                                            FadeIn(
                                              child: Column(
                                                children: [
                                                  const Text('Alkoholenheter'),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        snapshot.data![
                                                                'alcohol_units']
                                                            .toStringAsFixed(1),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              height: 15,
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Informasjon',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  if (snapshot.hasData &&
                                      snapshot.data!['year'] != null &&
                                      snapshot.data!['year'] != 0)
                                    FadeIn(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Årgang'),
                                          const SizedBox(width: 50),
                                          Flexible(
                                            child: Text(
                                              snapshot.data!['year'].toString(),
                                              textAlign: TextAlign.end,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  if (snapshot.hasData &&
                                      snapshot.data!['year'] != null &&
                                      snapshot.data!['year'] != 0)
                                    const Divider(
                                      height: 8,
                                    ),
                                  if (snapshot.hasData &&
                                      snapshot.data!['taste'] != null)
                                    FadeIn(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Smak'),
                                          const SizedBox(width: 50),
                                          Flexible(
                                            child: Text(
                                              snapshot.data!['taste']
                                                  .toString()
                                                  .replaceAll(".", ""),
                                              textAlign: TextAlign.end,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  if (snapshot.hasData &&
                                      snapshot.data!['taste'] != null)
                                    const Divider(
                                      height: 8,
                                    ),
                                  if (snapshot.hasData &&
                                      snapshot.data!['aroma'] != null)
                                    FadeIn(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Lukt'),
                                          const SizedBox(width: 50),
                                          Flexible(
                                            child: Text(
                                              snapshot.data!['aroma']
                                                  .toString()
                                                  .replaceAll(".", ""),
                                              textAlign: TextAlign.end,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  if (snapshot.hasData &&
                                      snapshot.data!['aroma'] != null)
                                    const Divider(
                                      height: 8,
                                    ),
                                  if (snapshot.hasData &&
                                      snapshot.data!['color'] != null)
                                    FadeIn(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Farge'),
                                          const SizedBox(width: 50),
                                          Flexible(
                                            child: Text(
                                              snapshot.data!['color']
                                                  .toString()
                                                  .replaceAll(".", ""),
                                              textAlign: TextAlign.end,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  if (snapshot.hasData &&
                                      snapshot.data!['color'] != null)
                                    const Divider(
                                      height: 8,
                                    ),
                                  if (snapshot.hasData &&
                                      snapshot.data!['food_pairing'] != null)
                                    FadeIn(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Passer til'),
                                          const SizedBox(width: 50),
                                          Flexible(
                                            child: Text(
                                              snapshot.data!['food_pairing']
                                                  .toString()
                                                  .replaceAll(".", ""),
                                              textAlign: TextAlign.end,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  if (snapshot.hasData &&
                                      snapshot.data!['food_pairing'] != null)
                                    const Divider(
                                      height: 8,
                                    ),
                                  if (snapshot.hasData &&
                                      snapshot.data!['storable'] != null)
                                    FadeIn(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Lagring'),
                                          const SizedBox(width: 50),
                                          Flexible(
                                            child: Text(
                                              snapshot.data!['storable']
                                                  .toString()
                                                  .replaceAll(".", ""),
                                              textAlign: TextAlign.end,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  if (snapshot.hasData &&
                                      snapshot.data!['storable'] != null)
                                    const Divider(
                                      height: 8,
                                    ),
                                  if (snapshot.hasData &&
                                      snapshot.data!['raw_materials'] != null)
                                    FadeIn(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Råstoff'),
                                          const SizedBox(width: 50),
                                          Flexible(
                                            child: Text(
                                              snapshot.data!['raw_materials']
                                                  .toString()
                                                  .replaceAll(".", ""),
                                              textAlign: TextAlign.end,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  if (snapshot.hasData &&
                                      snapshot.data!['raw_materials'] != null)
                                    const Divider(
                                      height: 8,
                                    ),
                                  if (snapshot.hasData &&
                                      snapshot.data!['method'] != null)
                                    FadeIn(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Metode'),
                                          const SizedBox(width: 50),
                                          Flexible(
                                            child: Text(
                                              snapshot.data!['method']
                                                  .toString(),
                                              textAlign: TextAlign.end,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  if (snapshot.hasData &&
                                      snapshot.data!['method'] != null)
                                    const Divider(
                                      height: 8,
                                    ),
                                  if (snapshot.hasData &&
                                      snapshot.data!['allergens'] != null)
                                    FadeIn(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Allergen'),
                                          const SizedBox(width: 50),
                                          Flexible(
                                            child: Text(
                                              snapshot.data!['allergens']
                                                  .toString(),
                                              textAlign: TextAlign.end,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  if (snapshot.hasData &&
                                      snapshot.data!['allergens'] != null)
                                    const Divider(
                                      height: 8,
                                    ),
                                  if (snapshot.hasData &&
                                      snapshot.data!['brewery'] != null)
                                    FadeIn(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Bryggeri'),
                                          const SizedBox(width: 50),
                                          Flexible(
                                            child: Text(
                                              snapshot.data!['brewery'],
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (snapshot.hasData &&
                                      snapshot.data!['brewery'] != null)
                                    const Divider(
                                      height: 8,
                                    ),
                                  if (product.country != null)
                                    FadeIn(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Land'),
                                          const SizedBox(width: 50),
                                          Flexible(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  product.country!,
                                                  textAlign: TextAlign.end,
                                                ),
                                                if (product.country != null &&
                                                    countries[
                                                            product.country] !=
                                                        null &&
                                                    countries[product.country]!
                                                        .isNotEmpty)
                                                  Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 3,
                                                      ),
                                                      Flag.fromString(
                                                        countries[
                                                            product.country!]!,
                                                        height: 12,
                                                        width: 12 * 4 / 3,
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  if (product.country != null)
                                    const Divider(
                                      height: 8,
                                    ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Varenummer'),
                                      const SizedBox(width: 50),
                                      Flexible(
                                        child: Text(
                                          product.id.toString(),
                                          textAlign: TextAlign.end,
                                        ),
                                      )
                                    ],
                                  ),
                                  const Divider(
                                    height: 8,
                                  ),
                                  if (snapshot.hasData &&
                                      snapshot.data!['product_selection'] !=
                                          null)
                                    FadeIn(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Utvalg'),
                                          const SizedBox(width: 50),
                                          Flexible(
                                            child: Text(
                                              snapshot
                                                  .data!['product_selection'],
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Divider(
                              height: 15,
                            ),
                            Container(
                              height: _stockList.length < 6
                                  ? _stockList.length * 15 + 65
                                  : 165,
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Butikker med varen på lager',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  if (_stockList.isNotEmpty)
                                    Expanded(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: _stockList.length,
                                        itemBuilder: (context, index) {
                                          return Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(_stockList[index]
                                                      ['store_name']),
                                                  Text(
                                                    'På lager: ${_stockList[index]['quantity']}',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                              if (index < _stockList.length - 1)
                                                const Divider(
                                                  height: 5,
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  if (_stockList.isEmpty)
                                    Expanded(
                                      child: Center(
                                        child: const Text(
                                          'Ingen butikker har denne på lager',
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            ),
                            const Divider(
                              height: 20,
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Beskrivelse',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  if (snapshot.hasData &&
                                      snapshot.data!['description'] != null)
                                    Text(snapshot.data!['description']),
                                  if (snapshot.hasData &&
                                      snapshot.data!['description'] == '')
                                    Center(
                                      child: const Text(
                                        'Mangler beskrivelse',
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _showWrongUntappdMatchPopup(BuildContext context, int productId) {
    final _urlController = TextEditingController();

    Future<void> showDialogMessage(String title, String message) async {
      Widget continueButton = FilledButton.tonal(
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
        child: const Text(
          'OK',
        ),
      );

      AlertDialog alert = AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
        actions: [
          continueButton,
        ],
      );

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    void _submit() async {
      if (!ProductDetailScreen._formKey.currentState!.validate()) {
        return;
      }
      if (_urlController.text.isEmpty) {
        return;
      }
      final untappdUrl = _urlController.text;
      try {
        await ApiHelper.submitUntappdMatch(productId, untappdUrl);
        await showDialogMessage('Takk for hjelpen!',
            'Ditt forslag er nå sendt inn og vil bli behandlet innen kort tid.');
      } catch (error) {
        await showDialogMessage(
            'Det oppsto en feil',
            'Det oppsto en feil når vi forsøkte å sende forslaget ditt. '
                'Sjekk at linken er en korrekt untappd link eller prøv igjen senere.');
      }
      Navigator.of(context).pop();
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.27 +
          MediaQuery.of(context).viewInsets.bottom,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          Flexible(
            child: Form(
              key: ProductDetailScreen._formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  const Text('Untappd link',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    autocorrect: false,
                    autofocus: true,
                    controller: _urlController,
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vennligst skriv inn riktig Untappd link.';
                      }
                      if (!value.contains('https://untappd.com/b/') &&
                          !value.contains('https://untp.beer/')) {
                        return 'Ugyldig untappd link.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText:
                            'https://untappd.com/b/nogne-o-imperial-stout/42871',
                        floatingLabelBehavior: FloatingLabelBehavior.never),
                    onEditingComplete: () => FocusScope.of(context).unfocus(),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      _submit();
                    },
                    label: const Text('Send inn'),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showFriendsCheckinsPopup(BuildContext context, List<dynamic> checkins,
      MediaQueryData _mediaQueryData) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Column(
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
          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
            height: _mediaQueryData.size.height * 0.4 - 28,
            width: _mediaQueryData.size.width,
            child: ListView.builder(
                itemCount: checkins.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                foregroundImage:
                                    NetworkImage(checkins[index]['avatar']),
                                backgroundImage: AssetImage(
                                    'assets/images/default_avatar.png'),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                checkins[index]['username'],
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '${checkins[index]['rating'].toStringAsFixed(2)} ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              createRatingBar(
                                  rating: checkins[index]['rating'],
                                  size: 18,
                                  color: Colors.yellow[700]!),
                              Text(
                                ' (${checkins[index]['count']})',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Divider(
                        height: 10,
                      )
                    ],
                  );
                }),
          )
        ],
      ),
    );
  }

  Future<void> toggleWishlist(Auth auth, Product product, Cart cart) async {
    bool success = !wishlisted
        ? await UntappdHelper.addToWishlist(
            auth.apiToken, auth.untappdToken, product)
        : await UntappdHelper.removeFromWishlist(
            auth.apiToken, auth.untappdToken, product);
    setState(() {
      if (!wishlisted && success) {
        wishlisted = true;
        cart.updateCartItemsData();
      } else if (wishlisted && success) {
        wishlisted = false;
        cart.updateCartItemsData();
      }
    });
  }

  wrongUntappdMatch(Product product) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return _showWrongUntappdMatchPopup(context, product.id);
      },
    );
  }

  friendsCheckins(List<dynamic> checkins, MediaQueryData _mediaQueryData) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return _showFriendsCheckinsPopup(context, checkins, _mediaQueryData);
      },
    );
  }
}
