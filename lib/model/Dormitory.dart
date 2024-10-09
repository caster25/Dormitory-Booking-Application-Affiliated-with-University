class Dormitory {
  String id; 
  String name; 
  String roomType; 
  int occupants; 
  int price; 
  int maintenanceFee; 
  int furnitureFee; 
  int monthlyRent; 
  int securityDeposit; 
  int availableRooms; 
  int electricityRate; 
  int waterRate; 
  double rating; 
  String imageUrls; 
  List<String> tenants;
  String equipment;
  String address;

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
    required this.address
  });

  // Method to create a Dormitory instance from Firestore data
  factory Dormitory.fromFirestore(Map<String, dynamic> data, String id) {
    return Dormitory(
      id: id,
      name: data['name'] ?? '',
      roomType: data['roomType'] ?? '',
      occupants: data['occupants']?.toInt() ?? 0,
      price: data['price']?.toInt() ?? 0,
      maintenanceFee: data['maintenanceFee']?.toInt() ?? 0,
      furnitureFee: data['furnitureFee']?.toInt() ?? 0,
      monthlyRent: data['monthlyRent']?.toInt() ?? 0,
      securityDeposit: data['securityDeposit']?.toInt() ?? 0,
      availableRooms: data['availableRooms']?.toInt() ?? 0,
      electricityRate: data['electricityRate']?.toInt() ?? 0,
      waterRate: data['waterRate']?.toInt() ?? 0,
      rating: data['rating']?.toDouble() ?? 0.0,
      imageUrls: data['imageUrl'] ?? [],
      tenants: List<String>.from(data['tenants'] ?? []),
      equipment: data['equipment'] ?? '-',
      address: data['address']
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
      'address' : address
    };
  }
}
