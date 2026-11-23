import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../widgets/product_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(hintText: 'Search products', border: InputBorder.none),
          onSubmitted: (q) => context.read<SearchBloc>().add(SearchSubmitted(q)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _controller.clear();
              context.read<SearchBloc>().add(const SearchCleared());
            },
          ),
        ],
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) => switch (state) {
          SearchIdle() => const Center(child: Text('Type something and press search.')),
          SearchLoading() => const Center(child: CircularProgressIndicator()),
          SearchEmpty(:final query) => Center(child: Text('No products found for "$query".')),
          SearchError(:final message) => Center(child: Text(message)),
          SearchResults(:final products) => ListView.builder(
              itemCount: products.length,
              itemBuilder: (_, i) => ProductTile(products[i]),
            ),
        },
      ),
    );
  }
}
