import 'dart:convert';
import 'dart:io';

import 'package:api_catalog/bloc/search_bloc.dart';
import 'package:api_catalog/bloc/search_event.dart';
import 'package:api_catalog/bloc/search_state.dart';
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
  SearchBloc build() =>
      SearchBloc(ProductApi(client: MockClient((_) async => http.Response(page, 200))));

  blocTest<SearchBloc, SearchState>(
    'phone: loading then results',
    build: build,
    act: (b) => b.add(const SearchSubmitted('phone')),
    expect: () => [isA<SearchLoading>(), isA<SearchResults>()],
  );

  blocTest<SearchBloc, SearchState>(
    'blank query: stays idle (no state change emitted)',
    build: build,
    act: (b) => b.add(const SearchSubmitted(' ')),
    expect: () => [isA<SearchIdle>()],
  );
}
