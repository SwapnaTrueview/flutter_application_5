import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/product_model.dart';

class ProductLocationMap extends StatelessWidget {
  final List<Product> productList;

  const ProductLocationMap({super.key, required this.productList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Locations')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            productList[0].coordinates[0], // Default to the first product
            productList[0].coordinates[1],
          ),
          zoom: 5.0,
        ),
        markers: _createMarkers(),
      ),
    );
  }

  Set<Marker> _createMarkers() {
    return productList.map((product) {
      return Marker(
        markerId: MarkerId(product.id.toString()),
        position: LatLng(product.coordinates[0], product.coordinates[1]),
        infoWindow: InfoWindow(
          title: product.title,
          snippet: product.body, // Show description in the popup
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
    }).toSet();
  }
}
