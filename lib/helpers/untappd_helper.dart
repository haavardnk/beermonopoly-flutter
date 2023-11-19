import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/product.dart';

const _apiBaseUrl = 'https://api.beermonopoly.com/';
const _untappdBaseUrl = 'https://api.untappd.com/v4/';

class UntappdHelper {
  static Future<bool> addToWishlist(http.Client http, String apiToken,
      String untappdToken, Product product) async {
    try {
      final untappdResponse = await http.get(
        Uri.parse('$_untappdBaseUrl' +
            'user/wishlist/add' +
            '?access_token=$untappdToken&bid=${product.untappdId}'),
        headers: {'User-Agent': 'app:Beermonopoly'},
      );
      bool inWishlist =
          json.decode(utf8.decode(untappdResponse.bodyBytes))['meta']
                  ['error_detail'] ==
              'You already have this beer on your wish list!';
      final apiResponse = await http.post(
          Uri.parse(_apiBaseUrl + 'add_wishlist/' + '?beer_id=${product.id}'),
          headers: {
            'Authorization': 'Token $apiToken',
          });
      if (apiResponse.statusCode == 200 &&
          (untappdResponse.statusCode == 200 || inWishlist)) {
        return true;
      } else {
        return false;
      }
    } on SocketException {
      throw NoConnectionException();
    }
  }

  static Future<bool> removeFromWishlist(http.Client http, String apiToken,
      String untappdToken, Product product) async {
    try {
      final untappdResponse = await http.get(
        Uri.parse('$_untappdBaseUrl' +
            'user/wishlist/delete' +
            '?access_token=$untappdToken&bid=${product.untappdId}'),
        headers: {'User-Agent': 'app:Beermonopoly'},
      );
      bool notInWishlist =
          json.decode(utf8.decode(untappdResponse.bodyBytes))['meta']
                  ['error_detail'] ==
              "This beer doesn't exist on your Wish List.";
      final apiResponse = await http.post(
          Uri.parse(
              _apiBaseUrl + 'remove_wishlist/' + '?beer_id=${product.id}'),
          headers: {
            'Authorization': 'Token $apiToken',
          });

      if (apiResponse.statusCode == 200 &&
          (untappdResponse.statusCode == 200 || notInWishlist)) {
        return true;
      } else {
        return false;
      }
    } on SocketException {
      throw NoConnectionException();
    }
  }
}

class NoConnectionException implements Exception {}
