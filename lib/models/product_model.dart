class Product {
  final String id;
  final String title;
  final String body;
  final String imageUrl;
  final List<double> coordinates;
  final String userId;

  Product({
    required this.id,
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.coordinates,
    required this.userId,
  });

  // Factory constructor to create a Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      imageUrl: json['imageUrl'],
      coordinates: List<double>.from(json['coordinates']),
      userId: json['userId'],
    );
  }

  // Convert Product to JSON (if needed)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'coordinates': coordinates,
      'userId': userId,
    };
  }
}
