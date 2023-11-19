import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;

import 'package:beermonopoly/helpers/api_helper.dart';
import 'package:beermonopoly/providers/auth.dart';
import 'package:beermonopoly/providers/filter.dart';
import 'package:beermonopoly/models/stock_change.dart';
import 'package:beermonopoly/models/product.dart';
import 'package:beermonopoly/models/release.dart';

class MockClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockClient mockClient;
  late Auth auth;
  late Filter filter;

  setUp(() {
    mockClient = MockClient();
    auth = Auth();
    filter = Filter();
    registerFallbackValue(FakeUri());
  });

  group(
    "getDetailedProductInfo",
    () {
      test(
        "raises GenericHttpException when not receiving status code 200",
        () async {
          when(() => mockClient.get(any(), headers: {})).thenAnswer(((_) async {
            return http.Response('', 400);
          }));

          expect(
            () => ApiHelper.getDetailedProductInfo(mockClient, 1, auth, ''),
            throwsA(
              isA<GenericHttpException>(),
            ),
          );
        },
      );

      test(
        "raises NoConnectionException on SocketException",
        () async {
          when(() => mockClient.get(any(), headers: {})).thenAnswer(((_) async {
            throw SocketException('No connection');
          }));

          expect(
            () => ApiHelper.getDetailedProductInfo(mockClient, 1, auth, ''),
            throwsA(
              isA<NoConnectionException>(),
            ),
          );
        },
      );

      test(
        "get detailed info of product when not signed in",
        () async {
          when(
            () => mockClient.get(
              Uri.parse(
                  'https://api.beermonopoly.com/beers/?beers=123&fields=vmp_name,rating&all_stock=true'),
              headers: {},
            ),
          ).thenAnswer(((_) async {
            return http.Response(
              '{"count":1,"next":null,"previous":null,"results":[{"vmp_name":"Graff Niflheim Barrel Aged Stout","rating":4.13861}]}',
              200,
            );
          }));

          final detailedProductInfo = await ApiHelper.getDetailedProductInfo(
              mockClient, 123, auth, 'vmp_name,rating');

          expect(
            detailedProductInfo,
            {
              'vmp_name': 'Graff Niflheim Barrel Aged Stout',
              'rating': 4.13861,
            },
          );
        },
      );

      test(
        "get detailed info of product when signed in",
        () async {
          auth.apiToken = "123456";
          when(
            () => mockClient.get(
              Uri.parse(
                'https://api.beermonopoly.com/beers/?beers=123&fields=vmp_name,rating,user_checked_in&all_stock=true',
              ),
              headers: {
                'Authorization': 'Token 123456',
              },
            ),
          ).thenAnswer(((_) async {
            return http.Response(
              '{"count":1,"next":null,"previous":null,"results":[{"vmp_name":"Graff Niflheim Barrel Aged Stout","rating":4.13861,"user_checked_in":[{"rating":3.25,"count":1}]}]}',
              200,
            );
          }));

          final detailedProductInfo = await ApiHelper.getDetailedProductInfo(
              mockClient, 123, auth, 'vmp_name,rating,user_checked_in');

          expect(
            detailedProductInfo,
            {
              'vmp_name': 'Graff Niflheim Barrel Aged Stout',
              'rating': 4.13861,
              'user_checked_in': [
                {
                  'rating': 3.25,
                  'count': 1,
                }
              ]
            },
          );
        },
      );
    },
  );

  group(
    'checkStock',
    () {
      test(
        "raises GenericHttpException when not receiving status code 200",
        () async {
          when(() => mockClient.get(any())).thenAnswer(((_) async {
            return http.Response('', 400);
          }));

          expect(
            () => ApiHelper.checkStock(mockClient, '1,2,3', '110'),
            throwsA(
              isA<GenericHttpException>(),
            ),
          );
        },
      );

      test(
        "raises NoConnectionException on SocketException",
        () async {
          when(() => mockClient.get(any())).thenAnswer(((_) async {
            throw SocketException('No connection');
          }));

          expect(
            () => ApiHelper.checkStock(mockClient, '1,2,3', '110'),
            throwsA(
              isA<NoConnectionException>(),
            ),
          );
        },
      );
      test(
        "check stock of two beers in one store",
        () async {
          when(
            () => mockClient.get(
              Uri.parse(
                  'https://api.beermonopoly.com/beers/?beers=1053802,1336902&store=121&fields=vmp_id,stock'),
            ),
          ).thenAnswer(((_) async {
            return http.Response(
              '{"count":2,"next":null,"previous":null,"results":[{"vmp_id":1053802,"stock":8},{"vmp_id":1336902,"stock":7}]}',
              200,
            );
          }));

          final stock =
              await ApiHelper.checkStock(mockClient, '1053802,1336902', '121');

          expect(stock, [
            {'vmp_id': 1053802, 'stock': 8},
            {'vmp_id': 1336902, 'stock': 7}
          ]);
        },
      );
    },
  );

  group(
    'getStockChangeList',
    () {
      test(
        "raises GenericHttpException when not receiving status code 200",
        () async {
          when(() => mockClient.get(
                any(),
                headers: {},
              )).thenAnswer(((_) async {
            return http.Response('', 400);
          }));

          expect(
            () => ApiHelper.getStockChangeList(mockClient, 1, auth, 25, '121'),
            throwsA(
              isA<GenericHttpException>(),
            ),
          );
        },
      );

      test(
        "raises NoConnectionException on SocketException",
        () async {
          when(() => mockClient.get(
                any(),
                headers: {},
              )).thenAnswer(((_) async {
            throw SocketException('No connection');
          }));

          expect(
            () => ApiHelper.getStockChangeList(mockClient, 1, auth, 25, '121'),
            throwsA(
              isA<NoConnectionException>(),
            ),
          );
        },
      );

      test(
        "get stock change from store when not signed in",
        () async {
          when(
            () => mockClient.get(
              Uri.parse(
                  'https://api.beermonopoly.com/stockchange/?store=472&page=1&page_size=1'),
              headers: {},
            ),
          ).thenAnswer(((_) async {
            return http.Response(
              """
            {
              "count": 322,
              "next": "http://api.beermonopoly.com/stockchange/?page=2&page_size=1&store=472",
              "previous": null,
              "results": [
                {
                  "store": 472,
                  "quantity": 21,
                  "stock_updated": "2024-01-06T00:16:49.751890+01:00",
                  "stocked_at": "2024-01-06T00:16:49.751471+01:00",
                  "unstocked_at": null,
                  "beer": {
                    "vmp_id": 16655102,
                    "vmp_name": "Parish Ghost In The Machine DIPA",
                    "price": 174.9,
                    "style": "IPA - Imperial / Double New England / Hazy",
                    "volume": 0.473
                  }
                }
              ]
            }
            """,
              200,
            );
          }));

          final stockChangeList =
              await ApiHelper.getStockChangeList(mockClient, 1, auth, 1, '472');

          expect(
            stockChangeList,
            [
              StockChange(
                store: '472',
                quantity: 21,
                stock_updated:
                    DateTime.parse("2024-01-06T00:16:49.751890+01:00"),
                stocked_at: DateTime.parse("2024-01-06T00:16:49.751471"),
                unstocked_at: null,
                stock_unstock_at: DateTime.parse("2024-01-06T00:16:49.751471"),
                product: Product(
                  id: 16655102,
                  name: "Parish Ghost In The Machine DIPA",
                  style: "IPA - Imperial / Double New England / Hazy",
                  price: 174.9,
                  volume: 0.473,
                  userWishlisted: false,
                ),
              )
            ],
          );
        },
      );
      test(
        "get stock change from store when signed in",
        () async {
          auth.apiToken = "123456";
          when(
            () => mockClient.get(
              Uri.parse(
                  'https://api.beermonopoly.com/stockchange/?store=472&page=1&page_size=1'),
              headers: {
                'Authorization': 'Token 123456',
              },
            ),
          ).thenAnswer(((_) async {
            return http.Response(
              """
            {
              "count": 322,
              "next": "http://api.beermonopoly.com/stockchange/?page=2&page_size=1&store=472",
              "previous": null,
              "results": [
                {
                  "store": 472,
                  "quantity": 21,
                  "stock_updated": "2024-01-06T00:16:49.751890+01:00",
                  "stocked_at": "2024-01-06T00:16:49.751471+01:00",
                  "unstocked_at": null,
                  "beer": {
                    "vmp_id": 16655102,
                    "vmp_name": "Parish Ghost In The Machine DIPA",
                    "price": 174.9,
                    "style": "IPA - Imperial / Double New England / Hazy",
                    "volume": 0.473,
                    "user_checked_in": [
                      {
                        "rating": 3.7,
                        "count": 1
                      }
                    ],
                    "user_wishlisted": true
                  }
                }
              ]
            }
            """,
              200,
            );
          }));

          final stockChangeList =
              await ApiHelper.getStockChangeList(mockClient, 1, auth, 1, '472');

          expect(
            stockChangeList,
            [
              StockChange(
                store: '472',
                quantity: 21,
                stock_updated:
                    DateTime.parse("2024-01-06T00:16:49.751890+01:00"),
                stocked_at: DateTime.parse("2024-01-06T00:16:49.751471"),
                unstocked_at: null,
                stock_unstock_at: DateTime.parse("2024-01-06T00:16:49.751471"),
                product: Product(
                  id: 16655102,
                  name: "Parish Ghost In The Machine DIPA",
                  style: "IPA - Imperial / Double New England / Hazy",
                  price: 174.9,
                  volume: 0.473,
                  userRating: 3.7,
                  userWishlisted: true,
                ),
              )
            ],
          );
        },
      );
    },
  );

  group(
    'getProductList',
    () {
      test(
        "raises GenericHttpException when not receiving status code 200",
        () async {
          when(() => mockClient.get(
                any(),
                headers: {},
              )).thenAnswer(((_) async {
            return http.Response('', 400);
          }));

          expect(
            () => ApiHelper.getProductList(mockClient, 1, filter, auth, 25),
            throwsA(
              isA<GenericHttpException>(),
            ),
          );
        },
      );

      test(
        "raises NoConnectionException on SocketException",
        () async {
          when(() => mockClient.get(
                any(),
                headers: {},
              )).thenAnswer(((_) async {
            throw SocketException('No connection');
          }));

          expect(
            () => ApiHelper.getProductList(mockClient, 1, filter, auth, 25),
            throwsA(
              isA<NoConnectionException>(),
            ),
          );
        },
      );

      test(
        "get product list when not signed in with filter and alternative style",
        () async {
          filter.style = 'mead';
          filter.ppvLow = '2.3';
          when(
            () => mockClient.get(
              Uri.parse(
                  'https://api.beermonopoly.com/beers/?fields=vmp_id,vmp_name,price,rating,checkins,label_sm_url,main_category,sub_category,style,stock,abv,user_checked_in,user_wishlisted,volume,price_per_volume,vmp_url,untpd_url,untpd_id,country,product_selection&active=True&price_low=&price_high=&ppv_high=&ppv_low=2.3&abv_high=&abv_low=&ordering=-rating&style=mead&country=&product_selection=&search=&release=&exclude_allergen=&page=1&page_size=1'),
              headers: {},
            ),
          ).thenAnswer(((_) async {
            return http.Response(
              """
            {
              "count": 3661,
              "next": "http://api.beermonopoly.com/beers/?abv_high=&abv_low=&active=True&country=&exclude_allergen=&fields=vmp_id%2Cvmp_name%2Cprice%2Crating%2Ccheckins%2Clabel_sm_url%2Cmain_category%2Csub_category%2Cstyle%2Cstock%2Cabv%2Cuser_checked_in%2Cuser_wishlisted%2Cvolume%2Cprice_per_volume%2Cvmp_url%2Cuntpd_url%2Cuntpd_id%2Ccountry%2Cproduct_selection&ordering=-rating&page=2&page_size=1&ppv_high=&ppv_low=&price_high=&price_low=&product_selection=&release=&search=&style=",
              "previous": null,
              "results": [
                {
                  "vmp_id": 16655602,
                  "untpd_id": 5575146,
                  "vmp_name": "Marlobobo Wildberry Vanilla Trail 2022",
                  "country": "Norge",
                  "product_selection": "Tilleggsutvalget",
                  "price": 384.8,
                  "volume": 0.375,
                  "price_per_volume": 1026.1333333333334,
                  "abv": 12.5,
                  "rating": 4.72213,
                  "checkins": 61,
                  "main_category": "Mjod",
                  "vmp_url": "https://www.vinmonopolet.no/Land/Norge/Vestfold-og-Telemark/Holmestrand/Marlobobo-Wildberry-Vanilla-Trail-2022/p/16655602",
                  "untpd_url": "https://untappd.com/b/marlobobo-wildberry-vanilla-trail-2022/5575146",
                  "label_sm_url": "https://assets.untappd.com/site/beer_logos/beer-5575146_aafa4_sm.jpeg",
                  "user_checked_in": [],
                  "user_wishlisted": false,
                  "stock": null
                }
              ]
            }
            """,
              200,
            );
          }));

          final productList =
              await ApiHelper.getProductList(mockClient, 1, filter, auth, 1);

          expect(
            productList,
            [
              Product(
                id: 16655602,
                untappdId: 5575146,
                name: "Marlobobo Wildberry Vanilla Trail 2022",
                country: "Norge",
                product_selection: "Tilleggsutvalget",
                style: "Mjod",
                price: 384.8,
                volume: 0.375,
                pricePerVolume: 1026.1333333333334,
                abv: 12.5,
                imageUrl:
                    "https://assets.untappd.com/site/beer_logos/beer-5575146_aafa4_sm.jpeg",
                rating: 4.72213,
                checkins: 61,
                vmpUrl:
                    "https://www.vinmonopolet.no/Land/Norge/Vestfold-og-Telemark/Holmestrand/Marlobobo-Wildberry-Vanilla-Trail-2022/p/16655602",
                untappdUrl:
                    "https://untappd.com/b/marlobobo-wildberry-vanilla-trail-2022/5575146",
                userRating: null,
                userWishlisted: false,
                stock: null,
              ),
            ],
          );
        },
      );
      test(
        "get product list when signed in with release",
        () async {
          auth.apiToken = "123456";
          filter.releaseSortBy = "-abv";
          when(
            () => mockClient.get(
              Uri.parse(
                  "https://api.beermonopoly.com/beers/?fields=vmp_id,vmp_name,price,rating,checkins,label_sm_url,main_category,sub_category,style,stock,abv,user_checked_in,user_wishlisted,volume,price_per_volume,vmp_url,untpd_url,untpd_id,country,product_selection&release=januar&ordering=-abv&page=1&page_size=1"),
              headers: {
                'Authorization': 'Token 123456',
              },
            ),
          ).thenAnswer(((_) async {
            return http.Response(
              """
            {
              "count": 3661,
              "next": "http://api.beermonopoly.com/beers/?abv_high=&abv_low=&active=True&country=&exclude_allergen=&fields=vmp_id%2Cvmp_name%2Cprice%2Crating%2Ccheckins%2Clabel_sm_url%2Cmain_category%2Csub_category%2Cstyle%2Cstock%2Cabv%2Cuser_checked_in%2Cuser_wishlisted%2Cvolume%2Cprice_per_volume%2Cvmp_url%2Cuntpd_url%2Cuntpd_id%2Ccountry%2Cproduct_selection&ordering=-rating&page=2&page_size=1&ppv_high=&ppv_low=&price_high=&price_low=&product_selection=&release=&search=&style=",
              "previous": null,
              "results": [
                {
                  "vmp_id": 16655602,
                  "untpd_id": 5575146,
                  "vmp_name": "Marlobobo Wildberry Vanilla Trail 2022",
                  "country": "Norge",
                  "product_selection": "Tilleggsutvalget",
                  "price": 384.8,
                  "volume": 0.375,
                  "price_per_volume": 1026.1333333333334,
                  "abv": 12.5,
                  "rating": 4.72213,
                  "checkins": 61,
                  "style": "Mead - Melomel",
                  "vmp_url": "https://www.vinmonopolet.no/Land/Norge/Vestfold-og-Telemark/Holmestrand/Marlobobo-Wildberry-Vanilla-Trail-2022/p/16655602",
                  "untpd_url": "https://untappd.com/b/marlobobo-wildberry-vanilla-trail-2022/5575146",
                  "label_sm_url": "https://assets.untappd.com/site/beer_logos/beer-5575146_aafa4_sm.jpeg",
                  "user_checked_in": [],
                  "user_wishlisted": false,
                  "stock": 3,
                  "user_checked_in": [
                    {
                      "rating": 3.7,
                      "count": 1
                    }
                  ],
                  "user_wishlisted": true
                }
              ]
            }
            """,
              200,
            );
          }));

          final productList = await ApiHelper.getProductList(
            mockClient,
            1,
            filter,
            auth,
            1,
            Release(
              name: "januar",
              productSelections: [],
            ),
          );

          expect(
            productList,
            [
              Product(
                id: 16655602,
                untappdId: 5575146,
                name: "Marlobobo Wildberry Vanilla Trail 2022",
                country: "Norge",
                product_selection: "Tilleggsutvalget",
                style: "Mead - Melomel",
                price: 384.8,
                volume: 0.375,
                pricePerVolume: 1026.1333333333334,
                abv: 12.5,
                imageUrl:
                    "https://assets.untappd.com/site/beer_logos/beer-5575146_aafa4_sm.jpeg",
                rating: 4.72213,
                checkins: 61,
                vmpUrl:
                    "https://www.vinmonopolet.no/Land/Norge/Vestfold-og-Telemark/Holmestrand/Marlobobo-Wildberry-Vanilla-Trail-2022/p/16655602",
                untappdUrl:
                    "https://untappd.com/b/marlobobo-wildberry-vanilla-trail-2022/5575146",
                userRating: 3.7,
                userWishlisted: true,
                stock: 3,
              ),
            ],
          );
        },
      );
    },
  );

  group(
    'getProductsData',
    () {
      test(
        "raises GenericHttpException when not receiving status code 200",
        () async {
          when(() => mockClient.get(
                any(),
                headers: {},
              )).thenAnswer(((_) async {
            return http.Response('', 400);
          }));

          expect(
            () => ApiHelper.getProductsData(mockClient, '1,2,3', '123'),
            throwsA(
              isA<GenericHttpException>(),
            ),
          );
        },
      );

      test(
        "raises NoConnectionException on SocketException",
        () async {
          when(() => mockClient.get(
                any(),
                headers: {},
              )).thenAnswer(((_) async {
            throw SocketException('No connection');
          }));

          expect(
            () => ApiHelper.getProductsData(mockClient, '1,2,3', '123'),
            throwsA(
              isA<NoConnectionException>(),
            ),
          );
        },
      );
    },
  );
}
