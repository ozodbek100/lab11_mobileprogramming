import 'dart:convert';
import 'dart:io';

import 'package:api_catalog/cubit/products_cubit.dart';
import 'package:api_catalog/data/product_api.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final fixture = File('test/fixtures/product.json').readAsStringSync();
  final page = jsonEncode({
    'products': [jsonDecode(fixture)],
    'total': 1,
    'skip': 0,
    'limit': 20,
  });

  blocTest<ProductsCubit, ProductsState>(
    'success: loading then loaded',
    build: () => ProductsCubit(ProductApi(client: MockClient((_) async => http.Response(page, 200)))),
    act: (c) => c.load(),
    expect: () => [isA<ProductsLoading>(), isA<ProductsLoaded>()],
  );

  blocTest<ProductsCubit, ProductsState>(
    'failure: loading then error',
    build: () => ProductsCubit(ProductApi(client: MockClient((_) async => http.Response('x', 500)))),
    act: (c) => c.load(),
    expect: () => [isA<ProductsLoading>(), isA<ProductsError>()],
  );
}
