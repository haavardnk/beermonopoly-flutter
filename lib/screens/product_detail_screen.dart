import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/filter.dart';
import '../helpers/api_helper.dart';
import '../helpers/untappd_helper.dart';
import '../helpers/app_launcher.dart';
import '../models/product.dart';
import '../widgets/rating_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);
  static const routeName = '/product-detail';
  static final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late bool wishlisted;
  bool init = false;

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
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    final auth = Provider.of<Auth>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final filters = Provider.of<Filter>(context, listen: false);
    final _mediaQueryData = MediaQuery.of(context);
    final _tabletMode = _mediaQueryData.size.width >= 600 ? true : false;
    final _boxImageSize =
        _mediaQueryData.size.shortestSide * (_tabletMode ? 0.4 : 0.75);
    const fields =
        'label_hd_url,ibu,description,brewery,country,product_selection,all_stock,'
        'year,color,aroma,taste,storable,food_pairing,raw_materials,fullness,'
        'sweetness,freshness,bitterness,sugar,acid,method,allergens';

    if (init == false) {
      wishlisted = product.userWishlisted ?? false;
      init = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detaljer',
          style: TextStyle(color: Theme.of(context).textTheme.headline6!.color),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme:
            Theme.of(context).appBarTheme.iconTheme, //change your color here
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
                          ? const RotatedCornerDecoration(
                              color: Color(0xff01aed6),
                              textSpan: TextSpan(text: 'Ønsket'),
                              geometry: BadgeGeometry(
                                width: 60,
                                height: 60,
                                cornerRadius: 0,
                                alignment: BadgeAlignment.topRight,
                              ),
                            )
                          : null,
                      child: Container(
                        foregroundDecoration: product.userRating != null
                            ? const RotatedCornerDecoration(
                                color: Color(0xFFFBC02D),
                                textSpan: TextSpan(text: 'Smakt'),
                                geometry: BadgeGeometry(
                                  width: 60,
                                  height: 60,
                                  cornerRadius: 0,
                                  alignment: BadgeAlignment.topLeft,
                                ),
                              )
                            : null,
                        padding:
                            const EdgeInsets.only(top: 5, left: 5, right: 5),
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
                                tag: product.id,
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
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                          const SizedBox(height: 12),
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
                          const SizedBox(height: 12),
                          Text(product.style,
                              style: const TextStyle(
                                fontSize: 14,
                              )),
                          if (product.rating != null &&
                              product.userRating == null)
                            const SizedBox(height: 12),
                          if (product.rating != null)
                            product.userRating == null
                                ? Row(
                                    children: [
                                      Text(
                                        product.rating != null
                                            ? '${product.rating!.toStringAsFixed(2)} '
                                            : '0 ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      createRatingBar(
                                          rating: product.rating != null
                                              ? product.rating!
                                              : 0,
                                          size: 18),
                                      Text(
                                        product.checkins != null
                                            ? ' ${NumberFormat.compact().format(product.checkins)}'
                                            : '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  )
                                : IntrinsicHeight(
                                    child: Column(
                                      children: [
                                        const Divider(
                                          height: 25,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  'Global rating - ${NumberFormat.compact().format(product.checkins)}',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      product.userRating != null
                                                          ? '${product.rating!.toStringAsFixed(2)} '
                                                          : '0 ',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14),
                                                    ),
                                                    createRatingBar(
                                                        rating:
                                                            product.userRating !=
                                                                    null
                                                                ? product
                                                                    .rating!
                                                                : 0,
                                                        size: 18),
                                                  ],
                                                )
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                const Text(
                                                  'Din rating',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      product.userRating != null
                                                          ? '${product.userRating!.toStringAsFixed(2)} '
                                                          : '0 ',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    createRatingBar(
                                                        rating:
                                                            product.userRating !=
                                                                    null
                                                                ? product
                                                                    .userRating!
                                                                : 0,
                                                        size: 18),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
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
                              (snapshot.data!['freshness'] != null ||
                                  snapshot.data!['bitterness'] != null ||
                                  snapshot.data!['sweetness'] != null ||
                                  snapshot.data!['fullness'] != null))
                            const Divider(
                              height: 25,
                            ),
                          if (snapshot.hasData &&
                              (snapshot.data!['freshness'] != null ||
                                  snapshot.data!['bitterness'] != null ||
                                  snapshot.data!['sweetness'] != null ||
                                  snapshot.data!['fullness'] != null))
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (snapshot.data!['freshness'] != null)
                                  CircularPercentIndicator(
                                    radius: 50.0,
                                    lineWidth: 5.0,
                                    animation: true,
                                    percent:
                                        snapshot.data!['freshness'].toDouble() /
                                            12,
                                    center: Text(
                                        (snapshot.data!['freshness'] / 12 * 100)
                                                .toStringAsFixed(0) +
                                            '%'),
                                    backgroundColor: Colors.grey[300]!,
                                    progressColor: Colors.pink,
                                    circularStrokeCap: CircularStrokeCap.round,
                                    footer: const Text(
                                      "Friskhet",
                                    ),
                                  ),
                                if (snapshot.data!['fullness'] != null)
                                  CircularPercentIndicator(
                                    radius: 50.0,
                                    lineWidth: 5.0,
                                    animation: true,
                                    percent:
                                        snapshot.data!['fullness'].toDouble() /
                                            12,
                                    center: Text(
                                        (snapshot.data!['fullness'] / 12 * 100)
                                                .toStringAsFixed(0) +
                                            '%'),
                                    backgroundColor: Colors.grey[300]!,
                                    progressColor: Colors.pink,
                                    circularStrokeCap: CircularStrokeCap.round,
                                    footer: const Text(
                                      "Fylde",
                                    ),
                                  ),
                                if (snapshot.data!['bitterness'] != null)
                                  CircularPercentIndicator(
                                    radius: 50.0,
                                    lineWidth: 5.0,
                                    animation: true,
                                    percent: snapshot.data!['bitterness']
                                            .toDouble() /
                                        12,
                                    center: Text((snapshot.data!['bitterness'] /
                                                12 *
                                                100)
                                            .toStringAsFixed(0) +
                                        '%'),
                                    backgroundColor: Colors.grey[300]!,
                                    progressColor: Colors.pink,
                                    circularStrokeCap: CircularStrokeCap.round,
                                    footer: const Text(
                                      "Bitterhet",
                                    ),
                                  ),
                                if (snapshot.data!['sweetness'] != null)
                                  CircularPercentIndicator(
                                    radius: 50.0,
                                    lineWidth: 5.0,
                                    animation: true,
                                    percent:
                                        snapshot.data!['sweetness'].toDouble() /
                                            12,
                                    center: Text(
                                        (snapshot.data!['sweetness'] / 12 * 100)
                                                .toStringAsFixed(0) +
                                            '%'),
                                    backgroundColor: Colors.grey[300]!,
                                    progressColor: Colors.pink,
                                    circularStrokeCap: CircularStrokeCap.round,
                                    footer: const Text(
                                      "Sødme",
                                    ),
                                  )
                              ],
                            ),
                          const Divider(
                            height: 25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (product.abv != null)
                                Column(
                                  children: [
                                    const Text('Styrke'),
                                    Text('${product.abv} %'),
                                  ],
                                ),
                              if (product.volume != null)
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
                                      Text('${snapshot.data!['acid']} g/l'),
                                    ],
                                  ),
                                ),
                              if (snapshot.hasData &&
                                  snapshot.data!['sugar'] != null)
                                FadeIn(
                                  child: Column(
                                    children: [
                                      const Text('Sukker'),
                                      Text('${snapshot.data!['sugar']} g/l'),
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
                                      Text(snapshot.data!['ibu'].toString()),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 25,
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Informasjon',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(
                            height: 16,
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
                                      snapshot.data!['method'].toString(),
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
                                      snapshot.data!['allergens'].toString(),
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
                          if (snapshot.hasData &&
                              snapshot.data!['country'] != null)
                            FadeIn(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Land'),
                                  const SizedBox(width: 50),
                                  Flexible(
                                    child: Text(
                                      snapshot.data!['country'],
                                      textAlign: TextAlign.end,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          if ((snapshot.hasData &&
                              snapshot.data!['country'] != null))
                            const Divider(
                              height: 8,
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              snapshot.data!['product_selection'] != null)
                            FadeIn(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Utvalg'),
                                  const SizedBox(width: 50),
                                  Flexible(
                                    child: Text(
                                      snapshot.data!['product_selection'],
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
                      height: 50,
                    ),
                    Container(
                      height: 165,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Butikker med varen på lager',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(
                            height: 16,
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
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(_stockList[index]['store_name']),
                                          Text(
                                            'På lager: ${_stockList[index]['quantity']}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
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
                      height: 50,
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Beskrivelse',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(
                            height: 16,
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
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    if (auth.isAuth)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                        child: ElevatedButton.icon(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Color(0xff01aed6))),
                          onPressed: () async {
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
                          },
                          label: Text(!wishlisted
                              ? 'Legg i Untappd ønskeliste'
                              : 'Fjern fra Untappd ønskeliste'),
                          icon: Icon(!wishlisted
                              ? Icons.playlist_add
                              : Icons.playlist_remove),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet<void>(
                            isScrollControlled: true,
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24)),
                            ),
                            builder: (BuildContext context) {
                              return _showPopup(context, product.id);
                            },
                          );
                        },
                        label: Text(product.rating != null
                            ? 'Rapporter feil Untappd match'
                            : 'Foreslå untappd match'),
                        icon: const Icon(Icons.report),
                      ),
                    ),
                    if (product.untappdUrl != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            AppLauncher.launchUntappd(product);
                          },
                          label: const Text('Åpne i Untappd'),
                          icon: const Icon(Icons.open_in_browser),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          product.vmpUrl != null
                              ? launch(product.vmpUrl!)
                              : null;
                        },
                        label: const Text('Åpne i Vinmonopolet'),
                        icon: const Icon(Icons.open_in_browser),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                padding: _tabletMode &&
                        _mediaQueryData.orientation == Orientation.landscape
                    ? EdgeInsets.fromLTRB(_mediaQueryData.size.width * 0.15, 12,
                        _mediaQueryData.size.width * 0.15, 25)
                    : EdgeInsets.fromLTRB(12, 12, 12, 25),
                decoration: BoxDecoration(
                  color: Theme.of(context).bottomAppBarColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 2.0,
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    cart.addItem(product.id, product);
                    cart.updateCartItemsData();
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Lagt til i handlelisten!',
                          textAlign: TextAlign.center,
                        ),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'ANGRE',
                          onPressed: () {
                            cart.removeSingleItem(product.id);
                          },
                        ),
                      ),
                    );
                  },
                  child: Consumer<Cart>(
                    builder: (_, cart, __) => Stack(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                          decoration: BoxDecoration(
                            color: Colors.pink,
                            border: Border.all(
                              width: 1,
                              color: Colors.pink,
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Legg til i handleliste',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (cart.items.keys.contains(product.id))
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              // color: Theme.of(context).accentColor,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.white,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                cart.items[product.id]!.quantity.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink,
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _showPopup(BuildContext context, int productId) {
    final _urlController = TextEditingController();

    Future<void> showDialogMessage(String title, String message) async {
      Widget continueButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text(
          'Ok',
          style: TextStyle(
            color: Colors.pink,
          ),
        ),
      );

      AlertDialog alert = AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
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
      height: MediaQuery.of(context).size.height * 0.30 +
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
                  color: Colors.grey[500],
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
                      if (!value!.contains('https://untappd.com/b/')) {
                        return 'Ugyldig untappd link';
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
                  ElevatedButton.icon(
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
}
