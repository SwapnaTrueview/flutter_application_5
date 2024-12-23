// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_5/widgets/message_alert.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';
import 'package:geolocator/geolocator.dart';

class ProductController extends GetxController {
  final ProductRepository repository;
  var products = <Product>[].obs;
  var isLoading = true.obs;

  ProductController({required this.repository});

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  void fetchProducts() async {
    try {
      isLoading.value = true;
      products.value = await repository.fetchProducts();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<Position> getCurrentLocation(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await showDialog(
        context: context,
        builder: (context) => const MessageAlert(
          title: 'Location services are disabled. Please enable them.',
        ),
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await showDialog(
          context: context,
          builder: (context) => const MessageAlert(
            title: 'Location permissions are denied',
          ),
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await showDialog(
        context: context,
        builder: (context) => const MessageAlert(
          title:
              'Location permissions are permanently denied. Please enable them in settings.',
        ),
      );
    }

    // Use the updated `settings` parameter
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}
