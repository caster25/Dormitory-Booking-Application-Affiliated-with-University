class Dormitory {
  String? id; // Add an ID field
  String? address;
  int availableRooms;
  List<String> favorites; // Assuming this is a list of user IDs or similar
  String imageUrl;
  double latitude;
  double longitude;
  String name;
  int price;
  double rating;
  int reviewCount;
  List<String> tenants; // Assuming this is a list of user IDs for the tenants

  Dormitory({
    this.id, // Include id in the constructor
    this.address,
    required this.availableRooms,
    required this.favorites,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.tenants,
  });

  // Factory method to create a Dormitory object from a Firestore document
  factory Dormitory.fromMap(Map<String, dynamic> data, String documentId) {
    return Dormitory(
      id: documentId, // Set the id from the document ID
      address: data['address'] as String?,
      availableRooms: data['availableRooms'] as int? ?? 0,
      favorites: List<String>.from(data['favorites'] ?? []),
      imageUrl: data['imageUrl'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      name: data['name'] as String? ?? '',
      price: data['price'] as int? ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] as int? ?? 0,
      tenants: List<String>.from(data['tenants'] ?? []),
    );
  }

  // Method to convert the Dormitory object back to a Firestore document
  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'availableRooms': availableRooms,
      'favorites': favorites,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'price': price,
      'rating': rating,
      'reviewCount': reviewCount,
      'tenants': tenants,
    };
  }
}
