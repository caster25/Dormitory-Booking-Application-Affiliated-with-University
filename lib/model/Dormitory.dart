class Dormitory {
  String id; 
  String name; 
  String roomType; 
  int occupants; 
  double price; 
  double maintenanceFee; 
  double furnitureFee; 
  double monthlyRent; 
  double securityDeposit; 
  int availableRooms; 
  double electricityRate; 
  double waterRate; 
  double rating; 
  List<String> imageUrls; 
  List<String> tenants;
  String equipment;

  Dormitory({
    required this.id,
    required this.name,
    required this.roomType,
    required this.occupants,
    required this.price,
    required this.maintenanceFee,
    required this.furnitureFee,
    required this.monthlyRent,
    required this.securityDeposit,
    required this.availableRooms,
    required this.electricityRate,
    required this.waterRate,
    required this.rating,
    required this.imageUrls,
    required this.tenants,
    required this.equipment,
  });

  // Method to create a Dormitory instance from Firestore data
  factory Dormitory.fromFirestore(Map<String, dynamic> data, String id) {
    return Dormitory(
      id: id,
      name: data['name'] ?? '',
      roomType: data['roomType'] ?? '',
      occupants: data['occupants']?.toInt() ?? 0,
      price: data['price']?.toDouble() ?? 0.0,
      maintenanceFee: data['maintenanceFee']?.toDouble() ?? 0.0,
      furnitureFee: data['furnitureFee']?.toDouble() ?? 0.0,
      monthlyRent: data['monthlyRent']?.toDouble() ?? 0.0,
      securityDeposit: data['securityDeposit']?.toDouble() ?? 0.0,
      availableRooms: data['availableRooms']?.toInt() ?? 0,
      electricityRate: data['electricityRate']?.toDouble() ?? 0.0,
      waterRate: data['waterRate']?.toDouble() ?? 0.0,
      rating: data['rating']?.toDouble() ?? 0.0,
      imageUrls: List<String>.from(data['imageUrl'] ?? []),
      tenants: List<String>.from(data['tenants'] ?? []),
      equipment: data['equipment'] ?? '-',
    );
  }

  // Method to convert the Dormitory instance back to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'roomType': roomType,
      'occupants': occupants,
      'price': price,
      'maintenanceFee': maintenanceFee,
      'furnitureFee': furnitureFee,
      'monthlyRent': monthlyRent,
      'securityDeposit': securityDeposit,
      'availableRooms': availableRooms,
      'electricityRate': electricityRate,
      'waterRate': waterRate,
      'rating': rating,
      'imageUrl': imageUrls,
      'tenants': tenants,
      'equipment': equipment,
    };
  }
}
