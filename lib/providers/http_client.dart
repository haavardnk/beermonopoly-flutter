import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HttpClient with ChangeNotifier {
  final _apiClient = http.Client();
  final _untappdClient = http.Client();

  http.Client get apiClient {
    return _apiClient;
  }

  http.Client get untappdClient {
    return _untappdClient;
  }

  void destroy() {
    _apiClient.close();
    _untappdClient.close();
  }
}
