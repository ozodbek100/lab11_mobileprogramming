import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/details_cubit.dart';
import '../models/product.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: BlocBuilder<DetailsCubit, DetailsState>(
        builder: (context, state) => switch (state) {
          DetailsLoading() => const Center(child: CircularProgressIndicator()),
          DetailsError(:final message) => Center(child: Text(message)),
          DetailsLoaded(:final product) => _Body(product),
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body(this.p);
  final Product p;

  String _date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final d = p.dimensions;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final url in p.images)
                Image.network(url, errorBuilder: (_, _, _) => const Icon(Icons.broken_image)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(p.title, style: Theme.of(context).textTheme.headlineSmall),
        Text('\$${p.price.toStringAsFixed(2)} · ★ ${p.rating.toStringAsFixed(1)}'),
        const SizedBox(height: 8),
        Text(p.description),
        const SizedBox(height: 8),
        Text('Dimensions: ${d.width} × ${d.height} × ${d.depth}'),
        const Divider(height: 32),
        Text('Reviews (${p.reviews.length})', style: Theme.of(context).textTheme.titleMedium),
        for (final r in p.reviews)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('${'★' * r.rating}${'☆' * (5 - r.rating)}  ${r.reviewerName}'),
            subtitle: Text('${r.comment}\n${_date(r.date)}'),
            isThreeLine: true,
          ),
      ],
    );
  }
}
