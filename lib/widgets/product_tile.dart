import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/details_cubit.dart';
import '../data/product_api.dart';
import '../models/product.dart';
import '../screens/details_screen.dart';

class ProductTile extends StatelessWidget {
  const ProductTile(this.product, {super.key});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 56,
        height: 56,
        child: Image.network(
          product.thumbnail,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
        ),
      ),
      title: Text(product.title),
      subtitle: Text('\$${product.price.toStringAsFixed(2)} · ★ ${product.rating.toStringAsFixed(1)}'),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (c) => DetailsCubit(context.read<ProductApi>())..load(product.id),
          child: const DetailsScreen(),
        ),
      )),
    );
  }
}
