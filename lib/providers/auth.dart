import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../helpers/api_helper.dart';

class Auth with ChangeNotifier {
  String _apiToken = '';
  String _sessionToken = '';
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

  Future<bool> login(
      String email, String password, BuildContext context) async {
    const apiUrl = 'https://auth.beermonopoly.com/_allauth/app/v1/auth/login';
    try {
      final apiResponse = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-type': 'application/json',
        },
        body: jsonEncode(
          {
            "email": email,
            "password": password,
          },
        ),
      );
      final apiData = json.decode(apiResponse.body);
      if (apiResponse.statusCode == 200) {
        print(apiData);
        _apiToken = apiData['meta']['access_token'];
        _sessionToken = apiData['meta']['session_token'];
        userName = apiData['data']['user']['username'];

        notifyListeners();
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('apiToken', _apiToken);
        prefs.setString('sessionToken', _sessionToken);
        prefs.setString('userName', userName);

        return true;
      } else {
        print(apiResponse.statusCode);
        print(apiResponse.body);

        if (apiResponse.statusCode == 400 &&
            apiData['errors'][0]['code'] == 'email_password_mismatch') {
          throw ErrorDescription(
            'E-posten og/eller passordet du oppgav er ikke korrekt.',
          );
        }
        return false;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> resetPassword(String email, BuildContext context) async {
    const apiUrl =
        'https://auth.beermonopoly.com/_allauth/app/v1/auth/password/request';
    try {
      final apiResponse = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-type': 'application/json',
        },
        body: jsonEncode(
          {
            "email": email,
          },
        ),
      );
      if (apiResponse.statusCode == 200) {
        return true;
      } else if (apiResponse.statusCode == 400) {
        throw ErrorDescription(
          'En feil har oppstått, sjekk at e-posten er korrekt eller ta kontakt med Ølmonopolet.',
        );
      } else if (apiResponse.statusCode == 500) {
        throw ErrorDescription(
          'En konto med e-postadressen $email eksisterer ikke. Forsøk å registrer deg på nytt.',
        );
      } else {
        return false;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> registerWithEmail(String username, String password, String email,
      BuildContext context) async {
    const apiUrl = 'https://auth.beermonopoly.com/_allauth/app/v1/auth/signup';
    try {
      final apiResponse = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-type': 'application/json',
        },
        body: jsonEncode(
          {
            "email": email,
            "username": username,
            "password": password,
          },
        ),
      );
      final apiData = json.decode(apiResponse.body);
      if (apiResponse.statusCode == 200) {
        print(apiData);
        _apiToken = apiData['meta']['access_token'];
        _sessionToken = apiData['meta']['session_token'];
        userName = apiData['data']['user']['username'];

        notifyListeners();
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('apiToken', _apiToken);
        prefs.setString('sessionToken', _sessionToken);
        prefs.setString('userName', userName);

        return true;
      } else {
        print(apiResponse.statusCode);
        print(apiResponse.body);
        if (apiResponse.statusCode == 400 &&
            apiData['errors'][0]['code'] == 'email_taken') {
          throw ErrorDescription(
            'En bruker med denne e-posten finnes allerede.'
            '\n\n'
            'Hint: Dersom du tidligere har brukt Ølmonopolet med en Untappd bruker med samme e-post må du navigere til Logg inn og trykke glemt passord.',
          );
        }
        if (apiResponse.statusCode == 400 &&
            apiData['errors'][0]['code'] == 'username_taken') {
          throw ErrorDescription(
            'En bruker med dette brukernavnet finnes allerede.'
            '\n\n'
            'Hint: Dersom du tidligere har brukt Ølmonopolet med en Untappd bruker med samme brukernavn kan du navigere til Logg inn og trykke glemt passord.',
          );
        }
        return false;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> authenticateApple() async {
    const apiUrl =
        'https://auth.beermonopoly.com/_allauth/app/v1/auth/provider/token';

    try {
      // Check if app server is available before starting Apple Sign In
      final pingApiResponse = await http.post(Uri.parse(apiUrl));
      if (pingApiResponse.statusCode == 400) {
        // Start Apple sign in flow
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          webAuthenticationOptions: Platform.isIOS
              ? null
              : WebAuthenticationOptions(
                  clientId: 'com.beermonopoly.olmonopolet.android',
                  redirectUri: Uri.parse(
                    'https://auth.beermonopoly.com/accounts/apple/login/callback2/',
                  ),
                ),
        );
        final apiResponse = await http.post(Uri.parse('$apiUrl'),
            headers: {
              'Content-type': 'application/json',
            },
            body: jsonEncode({
              "provider": "apple",
              "process": "login",
              "token": {
                "client_id": Platform.isIOS
                    ? "com.beermonopoly.olmonopolet"
                    : "com.beermonopoly.olmonopolet.android",
                "id_token": credential.identityToken,
                "access_token": credential.authorizationCode,
              }
            }));
        final apiData = json.decode(apiResponse.body);
        print(apiData);
        _apiToken = apiData['meta']['access_token'];
        _sessionToken = apiData['meta']['session_token'];
        userName = apiData['data']['user']['username'];

        notifyListeners();
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('apiToken', _apiToken);
        prefs.setString('sessionToken', _sessionToken);
        prefs.setString('userName', userName);
      } else {
        throw Exception('No response from Ølmonopolet API');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> authenticateGoogle() async {
    const apiUrl =
        'https://auth.beermonopoly.com/_allauth/app/v1/auth/provider/token';
    const List<String> scopes = <String>[
      'email',
      'profile',
    ];
    final GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: scopes,
        serverClientId:
            "298612751636-7f92barukp4lh8quki4jsoa4k87rlv1l.apps.googleusercontent.com");

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? credential =
          await googleUser?.authentication;

      final apiResponse = await http.post(Uri.parse('$apiUrl'),
          headers: {
            'Content-type': 'application/json',
          },
          body: jsonEncode({
            "provider": "google",
            "process": "login",
            "token": {
              "client_id":
                  "298612751636-7f92barukp4lh8quki4jsoa4k87rlv1l.apps.googleusercontent.com",
              "id_token": credential!.idToken,
              "access_token": credential.accessToken,
            }
          }));
      final apiData = json.decode(apiResponse.body);
      print(apiData);
      _apiToken = apiData['meta']['access_token'];
      _sessionToken = apiData['meta']['session_token'];
      userName = apiData['data']['user']['username'];

      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('apiToken', _apiToken);
      prefs.setString('sessionToken', _sessionToken);
      prefs.setString('userName', userName);
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    _skipLogin = prefs.getBool('skipLogin') ?? false;
    _apiToken = prefs.getString('apiToken') ?? '';
    _sessionToken = prefs.getString('sessionToken') ?? '';
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
    const apiUrl = 'https://auth.beermonopoly.com/_allauth/app/v1/auth/session';
    try {
      http.delete(
        Uri.parse(apiUrl),
        headers: {
          'X-Session-Token': _sessionToken,
        },
      );
    } catch (error) {
      print(error);
    }

    _apiToken = '';
    _sessionToken = '';
    _untappdToken = '';
    userName = '';
    userAvatarUrl = '';
    _skipLogin = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("apiToken");
    prefs.remove("sessionToken");
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
