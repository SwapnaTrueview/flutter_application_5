import 'package:flutter/material.dart';
import 'package:flutter_application_5/views/product_locations_on_map.dart';
import 'package:flutter_application_5/widgets/product_card.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../repositories/product_repository.dart';
import 'directions_screen.dart';

class ProductListingScreen extends StatelessWidget {
  get controller => Get.put(
        ProductController(repository: ProductRepository()),
      );

  const ProductListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products Listing'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (controller.products.isEmpty) {
                // Show "No Products" message or image
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/no_product.png', // Placeholder image
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Products Available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    return ProductCard(
                      product: product,
                      onViewDirection: () {
                        Get.to(() => DirectionsScreen(product: product));
                      },
                    );
                  },
                );
              }
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(
            () => ProductLocationMap(productList: controller.products),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.location_on_rounded),
      ),
    );
  }
}
