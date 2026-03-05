import 'package:flutter/material.dart';
import '../models/product.dart';

class CartPage extends StatefulWidget {
  final List<Product> cart;

  const CartPage({super.key, required this.cart});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  void removeFromCart(int index) {
    setState(() {
      widget.cart.removeAt(index);
    });
  }

  double parsePrice(String price) {
    return double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  }

  double get total => widget.cart.fold(0, (sum, p) => sum + parsePrice(p.price));

  void checkout() {
    if (widget.cart.isEmpty) return;
    setState(() {
      widget.cart.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order placed successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: widget.cart.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('Your cart is empty', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: widget.cart.length,
        itemBuilder: (context, index) {
          final product = widget.cart[index];
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
                    icon: const Icon(Icons.close, color: Colors.red, size: 20),
                    onPressed: () => removeFromCart(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: widget.cart.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: checkout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('Checkout (\$${total.toStringAsFixed(0)})', style: const TextStyle(fontSize: 16)),
        ),
      )
          : null,
    );
  }
}