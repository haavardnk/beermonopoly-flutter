import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:cronet_http/cronet_http.dart';
import 'package:cupertino_http/cupertino_http.dart';

Client httpClient() {
  if (Platform.isAndroid) {
    final engine =
        CronetEngine.build(cacheMode: CacheMode.memory, cacheMaxSize: 1000000);
    return CronetClient.fromCronetEngine(engine);
  }
  if (Platform.isIOS || Platform.isMacOS) {
    final config = URLSessionConfiguration.ephemeralSessionConfiguration()
      ..cache = URLCache.withCapacity(memoryCapacity: 1000000);
    return CupertinoClient.fromSessionConfiguration(config);
  }
  return IOClient();
}

class HttpClient with ChangeNotifier {
  final _apiClient = httpClient();
  final _untappdClient = httpClient();

  get apiClient {
    return _apiClient;
  }

  get untappdClient {
    return _untappdClient;
  }

  void destroy() {
    _apiClient.close();
    _untappdClient.close();
  }
}
