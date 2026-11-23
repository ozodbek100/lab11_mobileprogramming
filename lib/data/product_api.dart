import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/product_page.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ProductApi {
  /// [delayMs] is only for the T15 experiment (DummyJSON waits that long).
  ProductApi({http.Client? client, this.delayMs}) : _client = client ?? http.Client();

  final http.Client _client;
  final int? delayMs;
  static const _host = 'dummyjson.com';

  Future<ProductPage> getProducts({int limit = 20, int skip = 0}) =>
      _get(Uri.https(_host, '/products', {'limit': '$limit', 'skip': '$skip'}),
          ProductPage.fromJson);

  Future<Product> getProduct(int id) =>
      _get(Uri.https(_host, '/products/$id'), Product.fromJson);

  Future<ProductPage> search(String query) => _get(
        Uri.https(_host, '/products/search', {
          'q': query,
          if (delayMs != null) 'delay': '$delayMs',
        }),
        ProductPage.fromJson,
      );

  Future<T> _get<T>(Uri uri, T Function(Map<String, dynamic>) parse) async {
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 404) {
        throw const ApiException('Not found.');
      }
      if (response.statusCode != 200) {
        throw ApiException('Server answered ${response.statusCode}. Please try again later.');
      }
      return parse(jsonDecode(response.body) as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('The server took too long to answer. Please try again.');
    } on SocketException {
      throw const ApiException('No internet connection.');
    } on http.ClientException {
      throw const ApiException('No internet connection.');
    } on FormatException {
      throw const ApiException('The server sent data we could not read.');
    } on TypeError {
      throw const ApiException('The server sent data in an unexpected shape.');
    }
  }
}
