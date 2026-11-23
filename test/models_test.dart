import 'dart:convert';
import 'dart:io';

import 'package:api_catalog/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the saved fixture', () {
    final json = jsonDecode(File('test/fixtures/product.json').readAsStringSync())
        as Map<String, dynamic>;
    final p = Product.fromJson(json);
    expect(p.title, 'Essence Mascara Lash Princess');
    expect(p.price, isA<double>());
    expect(p.tags, ['beauty', 'mascara']);
    expect(p.reviews, hasLength(3));
    expect(p.dimensions.width, 15.14);
  });

  test('missing brand and tags do not crash; tags become an empty list', () {
    final p = Product.fromJson({
      'id': 2,
      'title': 'X',
      'price': 10, // int on purpose
      'rating': 4,
      'thumbnail': 'http://t',
      'dimensions': {'width': 1, 'height': 2, 'depth': 3},
    });
    expect(p.brand, isNull);
    expect(p.tags, isEmpty);
    expect(p.price, 10.0);
  });
}
