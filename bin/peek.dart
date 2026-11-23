import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Future<void> main() async {
  final response = await http.get(Uri.parse('https://dummyjson.com/products/1'));
  stdout.writeln(response.statusCode);
  final json = jsonDecode(response.body) as Map<String, dynamic>;
  stdout.writeln(json['title']);
  stdout.writeln(json['dimensions'].runtimeType);
}