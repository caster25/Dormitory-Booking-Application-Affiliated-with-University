class Dormitory { 
  String? id;
  String? address;
  int availableRooms;
  List<String> favorites; 
  List<String> imageUrl;
  double latitude;
  double longitude;
  String name;
  int price;
  double rating;
  int reviewCount;
  List<String> tenants;
  String? residentType; // ประเภทผู้พัก
  String? roomType; // ประเภทห้อง
  int? occupancy; // จำนวนคนพัก
  double? roomRate; // อัตราค่าห้องพัก
  double? maintenanceFee; // ค่าบำรุงหอ
  double? electricityRate; // ค่าไฟหน่วยละ
  double? waterRate; // ค่าน้ำหน่วยละ
  double? furnitureFee; // ค่าเฟอร์นิเจอร์เพิ่มเติม
  double? damageDeposit; // ค่าประกันความเสียหาย
  List<String>? roomFacilities; // อุปกรณ์ที่มีในห้องพัก

  Dormitory({
    this.id,
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
    this.residentType,
    this.roomType,
    this.occupancy,
    this.roomRate,
    this.maintenanceFee,
    this.electricityRate,
    this.waterRate,
    this.furnitureFee,
    this.damageDeposit,
    this.roomFacilities,
  });

  factory Dormitory.fromMap(Map<String, dynamic> data, String documentId) {
    return Dormitory(
      id: documentId,
      address: data['address'] as String?,
      availableRooms: data['availableRooms'] as int? ?? 0,
      favorites: List<String>.from(data['favorites'] ?? []),
      imageUrl: List<String>.from(data['imageUrl'] ?? []),
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      name: data['name'] as String? ?? '',
      price: data['price'] as int? ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] as int? ?? 0,
      tenants: List<String>.from(data['tenants'] ?? []),
      // Map new fields
      residentType: data['residentType'] as String?,
      roomType: data['roomType'] as String?,
      occupancy: data['occupancy'] as int?,
      roomRate: (data['roomRate'] as num?)?.toDouble(),
      maintenanceFee: (data['maintenanceFee'] as num?)?.toDouble(),
      electricityRate: (data['electricityRate'] as num?)?.toDouble(),
      waterRate: (data['waterRate'] as num?)?.toDouble(),
      furnitureFee: (data['furnitureFee'] as num?)?.toDouble(),
      damageDeposit: (data['damageDeposit'] as num?)?.toDouble(),
      roomFacilities: List<String>.from(data['roomFacilities'] ?? []),
    );
  }

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
      // Add new fields to map
      'residentType': residentType,
      'roomType': roomType,
      'occupancy': occupancy,
      'roomRate': roomRate,
      'maintenanceFee': maintenanceFee,
      'electricityRate': electricityRate,
      'waterRate': waterRate,
      'furnitureFee': furnitureFee,
      'damageDeposit': damageDeposit,
      'roomFacilities': roomFacilities,
    };
  }
}
