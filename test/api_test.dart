import 'dart:convert';
import 'dart:io';

import 'package:api_catalog/data/product_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final fixture = File('test/fixtures/product.json').readAsStringSync();

  test('getProducts returns one product from a mocked page', () async {
    final body = jsonEncode({
      'products': [jsonDecode(fixture)],
      'total': 1,
      'skip': 0,
      'limit': 20,
    });
    final api = ProductApi(client: MockClient((_) async => http.Response(body, 200)));
    final page = await api.getProducts();
    expect(page.products, hasLength(1));
  });

  test('getProduct throws ApiException on 404', () {
    final api = ProductApi(
      client: MockClient((_) async => http.Response('{"message":"nope"}', 404)),
    );
    expect(api.getProduct(0), throwsA(isA<ApiException>()));
  });
}
