import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import '../helpers/api_helper.dart';

class Auth with ChangeNotifier {
  String _apiToken = '';
  String _untappdToken = '';
  String userName = '';
  String userAvatarUrl = '';
  List<String> checkedInStyles = [];
  bool _skipLogin = false;

  late http.Client _client;
  void update(http.Client client) {
    _client = client;
  }

  bool get isAuth {
    return _apiToken.isNotEmpty;
  }

  bool get isAuthOrSkipLogin {
    return _skipLogin || _apiToken.isNotEmpty;
  }

  String get apiToken {
    return _apiToken;
  }

  void set apiToken(token) {
    _apiToken = token;
  }

  String get untappdToken {
    return _untappdToken;
  }

  void skipLogin(bool value) async {
    _skipLogin = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('skipLogin', _skipLogin);
  }

  Future<void> authenticate() async {
    const oauthUrl =
        'https://auth.beermonopoly.com/connect/untappd?callback=com.beermonopoly.olmonopolet://callback';
    const callbackUrl = 'com.beermonopoly.olmonopolet';
    const apiUrl = 'https://api.beermonopoly.com/auth/untappd/';
    const profileUrl = 'https://api.untappd.com/v4/user/info/';

    try {
      // Get Untappd token
      final untappdResponse = await FlutterWebAuth.authenticate(
          url: oauthUrl, callbackUrlScheme: callbackUrl);
      final untappdToken =
          Uri.parse(untappdResponse).queryParameters['access_token'];
      // Get API token
      final apiResponse =
          await http.post(Uri.parse('$apiUrl?access_token=$untappdToken'),
              headers: {
                'Content-type': 'application/json',
              },
              body: jsonEncode({'access_token': untappdToken}));
      final apiData = json.decode(apiResponse.body);
      if (apiData['error'] != null) {
        throw HttpException(apiData['error']['message']);
      }
      _apiToken = apiData['key'];
      _untappdToken = untappdToken ?? '';
      // Get Untappd profile
      final untappdProfileResponse = await http.get(
        Uri.parse('$profileUrl?access_token=$_untappdToken&compact=true'),
        headers: {'User-Agent': 'app:Beermonopoly'},
      );
      final untappdProfileData = json.decode(untappdProfileResponse.body);
      userName = untappdProfileData['response']['user']['user_name'];
      userAvatarUrl = untappdProfileData['response']['user']['user_avatar'];

      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('apiToken', _apiToken);
      prefs.setString('untappdToken', _untappdToken);
      prefs.setString('userName', userName);
      prefs.setString('userAvatarUrl', userAvatarUrl);
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    _skipLogin = prefs.getBool('skipLogin') ?? false;
    _apiToken = prefs.getString('apiToken') ?? '';
    _untappdToken = prefs.getString('untappdToken') ?? '';
    userName = prefs.getString('userName') ?? '';
    userAvatarUrl = prefs.getString('userAvatarUrl') ?? '';
    if (_apiToken.isEmpty) {
      if (_skipLogin) {
        notifyListeners();
        return true;
      }
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _apiToken = '';
    _untappdToken = '';
    userName = '';
    userAvatarUrl = '';
    _skipLogin = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("apiToken");
    prefs.remove("untappdToken");
    prefs.remove("userName");
    prefs.remove("userAvatarUrl");
  }

  Future<void> getCheckedInStyles() async {
    if (_apiToken.isNotEmpty) {
      checkedInStyles = await ApiHelper.getCheckedInStyles(_client, _apiToken);
    }
  }
}
