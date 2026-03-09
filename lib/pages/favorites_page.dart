import 'package:flutter/material.dart';
import '../models/product.dart';

class FavoritesPage extends StatelessWidget {
  final List<Product> favorites;
  final Function(Product) onToggleFavorite;

  const FavoritesPage({
    super.key,
    required this.favorites,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: favorites.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No favorites yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final product = favorites[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Image.network(product.image, width: 50, fit: BoxFit.contain),
              title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(product.tagline, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.price,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red, size: 20),
                    onPressed: () => onToggleFavorite(product),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}