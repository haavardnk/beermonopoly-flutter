import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/store.dart';
import '../providers/filter.dart';
import '../providers/auth.dart';

//const _baseUrl = 'http://127.0.0.1:8000/';
const _baseUrl = 'https://api.beermonopoly.com/';

class ApiHelper {
  static Future<Map<String, dynamic>> getDetailedProductInfo(
      int productId, String apiToken, String fields) async {
    final Map<String, String> headers = apiToken.isNotEmpty
        ? {
            'Authorization': 'Token $apiToken',
          }
        : {};
    final url = Uri.parse(
        '${_baseUrl}beers/?beers=$productId&fields=$fields&all_stock=true');
    try {
      final response = await http.get(
        url,
        headers: headers,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            json.decode(utf8.decode(response.bodyBytes))['results'][0];
        return jsonResponse;
      } else {
        throw GenericHttpException();
      }
    } on SocketException {
      throw NoConnectionException();
    }
  }

  static Future<List<dynamic>> checkStock(
      String productIds, String stores) async {
    final url = Uri.parse(
        '${_baseUrl}beers/?beers=$productIds&store=$stores&fields=vmp_id,stock');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse =
            json.decode(utf8.decode(response.bodyBytes))['results'];
        return jsonResponse;
      } else {
        throw GenericHttpException();
      }
    } on SocketException {
      throw NoConnectionException();
    }
  }

  static Future<List<Product>> getProductList(
      int page, Filter filter, Auth auth, int pageSize) async {
    const fields =
        'vmp_id,vmp_name,price,rating,checkins,label_sm_url,main_category,'
        'sub_category,style,stock,abv,user_checked_in,user_wishlisted,'
        'volume,price_per_volume,vmp_url,untpd_url,untpd_id,country';
    final Map<String, String> headers = auth.apiToken.isNotEmpty
        ? {
            'Authorization': 'Token ${auth.apiToken}',
          }
        : {};
    try {
      final response = await http.get(
        _apiProductUrlBuilder(fields, page, filter, pageSize),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final jsonResponse =
            json.decode(utf8.decode(response.bodyBytes))['results'];
        List<Product> products = List<Product>.from(
          jsonResponse.map(
            (product) => Product.fromJson(product),
          ),
        );
        return products;
      } else if (response.statusCode == 401) {
        auth.logout();
        return [];
      } else {
        throw GenericHttpException();
      }
    } on SocketException {
      throw NoConnectionException();
    }
  }

  static Future<List<Product>> getProductsData(
      String productIds, String apiToken) async {
    const fields =
        'vmp_id,vmp_name,price,rating,checkins,label_sm_url,main_category,'
        'sub_category,style,stock,abv,user_checked_in,user_wishlisted,'
        'volume,price_per_volume,vmp_url,untpd_url,untpd_id,country';
    final Map<String, String> headers = apiToken.isNotEmpty
        ? {
            'Authorization': 'Token $apiToken',
          }
        : {};
    final url = Uri.parse('${_baseUrl}beers/?beers=$productIds&fields=$fields');
    try {
      final response = await http.get(
        url,
        headers: headers,
      );
      if (response.statusCode == 200) {
        final jsonResponse =
            json.decode(utf8.decode(response.bodyBytes))['results'];
        List<Product> products = List<Product>.from(
          jsonResponse.map(
            (product) => Product.fromJson(product),
          ),
        );
        return products;
      } else {
        throw GenericHttpException();
      }
    } on SocketException {
      throw NoConnectionException();
    }
  }

  static Future<void> submitUntappdMatch(
      int productId, String untappdUrl) async {
    final jsonBody = json.encode({
      'beer': productId,
      'suggested_url': untappdUrl,
    });
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}wrongmatch/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonBody,
      );
      if (response.statusCode == 201) {
        return;
      } else {
        throw GenericHttpException();
      }
    } on SocketException {
      throw NoConnectionException();
    }
  }

  static Future<List<Store>> getStoreList() async {
    const fields = "store_id,name,gps_lat,gps_long";
    try {
      final response = await http.get(_apiStoreUrlBuilder(fields));
      if (response.statusCode == 200) {
        final jsonResponse =
            json.decode(utf8.decode(response.bodyBytes))['results'];
        List<Store> stores = List<Store>.from(
          jsonResponse.map(
            (store) => Store.fromJson(store),
          ),
        );
        return stores;
      } else {
        throw GenericHttpException();
      }
    } on SocketException {
      throw NoConnectionException();
    }
  }

  static Future<List<String>> getReleaseList() async {
    const fields = "name";
    try {
      final response = await http.get(_apiReleaseUrlBuilder(fields));
      if (response.statusCode == 200) {
        List<String> releases = [];
        final jsonResponse =
            json.decode(utf8.decode(response.bodyBytes))['results'];
        jsonResponse.forEach((release) => releases.add(release['name']));
        return releases;
      } else {
        throw GenericHttpException();
      }
    } on SocketException {
      throw NoConnectionException();
    }
  }

  static Future<void> updateFcmToken(String fcmToken, String apiToken) async {
    try {
      final response = await http.post(
          Uri.parse('${_baseUrl}notifications/set_token/?token=${fcmToken}'),
          headers: {
            'Authorization': 'Token $apiToken',
          });
      if (response.statusCode == 200) {
        print(response.body);
        return;
      } else {
        throw GenericHttpException();
      }
    } on SocketException {
      throw NoConnectionException();
    }
  }

  static Future<void> deleteUserAccount(Auth auth) async {
    try {
      final response = await http.delete(
        Uri.parse('${_baseUrl}auth/delete/'),
        headers: {
          'Authorization': 'Token ${auth.apiToken}',
        },
      );
      if (response.statusCode == 200) {
        return;
      } else {
        throw GenericHttpException();
      }
    } on SocketException {
      throw NoConnectionException();
    }
  }
}

Uri _apiProductUrlBuilder(
    String fields, int page, Filter filter, int pageSize) {
  var string = ('$_baseUrl'
      'beers/'
      '?fields=$fields'
      '&active=True'
      '&price_low=${filter.priceLow}'
      '&price_high=${filter.priceHigh}'
      '&ppv_high=${filter.ppvHigh}'
      '&ppv_low=${filter.ppvLow}'
      '&abv_high=${filter.abvHigh}'
      '&abv_low=${filter.abvLow}'
      '&ordering=${filter.sortBy}'
      '&style=${filter.style}'
      '&country=${filter.country}'
      '&product_selection=${filter.productSelection}'
      '&search=${filter.search}'
      '&release=${filter.release}'
      '&exclude_allergen=${filter.excludeAllergens}'
      '&page=$page'
      '&page_size=$pageSize');
  if (filter.storeId.isNotEmpty) {
    string = string + '&store=${filter.storeId}';
  }
  if (filter.checkIn == 1 || filter.sortBy.contains('checkin__rating')) {
    string = string + '&user_checkin=True';
  } else if (filter.checkIn == 2) {
    string = string + '&user_checkin=False';
  }
  if (filter.wishlisted == 1) {
    string = string + '&user_wishlisted=True';
  } else if (filter.wishlisted == 2) {
    string = string + '&user_wishlisted=False';
  }
  if (filter.deliverySelectedList[0] == true) {
    string = string + '&store_delivery=True';
  }
  if (filter.deliverySelectedList[1] == true) {
    string = string + '&post_delivery=True';
  }

  final url = Uri.parse(string);
  return url;
}

Uri _apiStoreUrlBuilder(String fields) {
  final url = Uri.parse(
    '$_baseUrl'
    'stores/'
    '?fields=$fields'
    '&page_size=500',
  );
  return url;
}

Uri _apiReleaseUrlBuilder(String fields) {
  final url = Uri.parse(
    '$_baseUrl'
    'release/'
    '?fields=$fields',
  );
  return url;
}

class GenericHttpException implements Exception {}

class NoConnectionException implements Exception {}
