import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/constants.dart';

class ProductRepository {
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(Constants.SERVER_URL));

      print(response.toString());

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        // Return an empty list if fetching fails
        return [];
      }
    } catch (e) {
      // Return an empty list in case of an error
      return [];
    }
  }
}
