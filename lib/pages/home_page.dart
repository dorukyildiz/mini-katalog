import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'detail_page.dart';
import 'cart_page.dart';
import 'favorites_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> products = [];
  List<Product> filtered = [];
  List<Product> cart = [];
  List<Product> favorites = [];
  final searchController = TextEditingController();
  bool isLoading = true;
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  String getCategory(Product p) {
    final name = p.name.toLowerCase();
    if (name.contains('iphone') || name.contains('phone se')) return 'Phone';
    if (name.contains('macbook')) return 'Laptop';
    if (name.contains('ipad')) return 'Tablet';
    if (name.contains('watch')) return 'Watch';
    if (name.contains('airpods') || name.contains('homepod')) return 'Audio';
    if (name.contains('imac')) return 'Desktop';
    if (name.contains('vision')) return 'XR';
    return 'Other';
  }

  List<String> get categories {
    final cats = products.map((p) => getCategory(p)).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  Future<void> loadProducts() async {
    try {
      final response = await http.get(Uri.parse('https://wantapi.com/products.php'));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> data = json['data'];
        setState(() {
          products = data.map((e) => Product.fromJson(e)).toList();
          filtered = products;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void applyFilters(String query) {
    setState(() {
      filtered = products.where((p) {
        final matchesSearch = p.name.toLowerCase().contains(query.toLowerCase());
        final matchesCategory = selectedCategory == 'All' || getCategory(p) == selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void toggleFavorite(Product product) {
    setState(() {
      if (favorites.any((f) => f.id == product.id)) {
        favorites.removeWhere((f) => f.id == product.id);
      } else {
        favorites.add(product);
      }
    });
  }

  bool isFavorite(Product product) {
    return favorites.any((f) => f.id == product.id);
  }

  void addToCart(Product product) {
    setState(() {
      cart.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesPage(
                    favorites: favorites,
                    onToggleFavorite: toggleFavorite,
                  ),
                ),
              );
            },
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartPage(cart: cart),
                    ),
                  );
                  setState(() {});
                },
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cart.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: (q) => applyFilters(q),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => selectedCategory = cat);
                      applyFilters(searchController.text);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final product = filtered[index];
                return ProductCard(
                  product: product,
                  isFavorite: isFavorite(product),
                  onFavorite: () => toggleFavorite(product),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(product: product),
                      ),
                    );
                    if (result == true) addToCart(product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}