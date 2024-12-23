import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/product_model.dart';

class MapView extends StatelessWidget {
  final List<Product> products;

  const MapView({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    // Check if there are any products to avoid empty list errors
    if (products.isEmpty) {
      return const Center(child: Text('No products available'));
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
          products[0].coordinates[0], // Latitude
          products[0].coordinates[1], // Longitude
        ),
        zoom: 12.0,
      ),
      markers: products
          .map(
            (product) => Marker(
              markerId: MarkerId(product.title),
              position: LatLng(
                product.coordinates[0], // Latitude
                product.coordinates[1], // Longitude
              ),
              infoWindow: InfoWindow(
                title: product.title,
                snippet: product.body,
              ),
            ),
          )
          .toSet(),
    );
  }
}
