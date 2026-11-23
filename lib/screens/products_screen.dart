import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/search_bloc.dart';
import '../cubit/products_cubit.dart';
import '../data/product_api.dart';
import '../widgets/product_tile.dart';
import 'search_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (c) => SearchBloc(context.read<ProductApi>()),
                child: const SearchScreen(),
              ),
            )),
          ),
        ],
      ),
      body: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) => switch (state) {
          ProductsLoading() => const Center(child: CircularProgressIndicator()),
          ProductsError(:final message) => Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(message),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => context.read<ProductsCubit>().load(),
                  child: const Text('Retry'),
                ),
              ]),
            ),
          ProductsLoaded(:final products, :final total, :final hasMore) => RefreshIndicator(
              onRefresh: () => context.read<ProductsCubit>().refresh(),
              child: ListView.builder(
                itemCount: products.length + (hasMore ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i < products.length) return ProductTile(products[i]);
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: OutlinedButton(
                      onPressed: () => context.read<ProductsCubit>().loadMore(),
                      child: Text('Load more (${products.length} of $total)'),
                    ),
                  );
                },
              ),
            ),
        },
      ),
    );
  }
}
