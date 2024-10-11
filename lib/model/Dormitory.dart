class Dormitory {
  String id;
  String name;
  String roomType;
  String occupants;
  int price;
  int maintenanceFee;
  int furnitureFee;
  int monthlyRent;
  int securityDeposit;
  int availableRooms;
  int electricityRate;
  int waterRate;
  double rating;
  String imageUrl; // แก้ไขจาก imageUrls ให้ตรงกับข้อมูล
  List<String> tenants;
  String equipment;
  String address;
  String dormType; // เพิ่มฟิลด์ dormType
  String rule; // เพิ่มฟิลด์ rule
  String submittedBy; // เพิ่มฟิลด์ submittedBy

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
    required this.imageUrl,
    required this.tenants,
    required this.equipment,
    required this.address,
    required this.dormType, // เพิ่มฟิลด์ dormType
    required this.rule, // เพิ่มฟิลด์ rule
    required this.submittedBy, // เพิ่มฟิลด์ submittedBy
  });

  // Method to create a Dormitory instance from Firestore data
  factory Dormitory.fromFirestore(Map<String, dynamic> data, String id) {
    return Dormitory(
      id: id,
      name: data['name'] ?? '',
      roomType: data['roomType'] ?? '',
      occupants: data['occupants'] ?? '',
      price: data['price']?.toInt() ?? 0,
      maintenanceFee: data['maintenanceFee']?.toInt() ?? 0,
      furnitureFee: data['furnitureFee']?.toInt() ?? 0,
      monthlyRent: data['monthlyRent']?.toInt() ?? 0,
      securityDeposit: data['securityDeposit']?.toInt() ?? 0,
      availableRooms: data['availableRooms']?.toInt() ?? 0,
      electricityRate: data['electricityRate']?.toInt() ?? 0,
      waterRate: data['waterRate']?.toInt() ?? 0,
      rating: data['rating']?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
      tenants: List<String>.from(data['tenants'] ?? []),
      equipment: data['equipment'] ?? '-',
      address: data['address'] ?? '',
      dormType: data['dormType'] ?? '', // เพิ่ม dormType
      rule: data['rule'] ?? '-', // เพิ่ม rule
      submittedBy: data['submittedBy'] ?? '', // เพิ่ม submittedBy
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
      'imageUrl': imageUrl,
      'tenants': tenants,
      'equipment': equipment,
      'address': address,
      'dormType': dormType, // เพิ่ม dormType
      'rule': rule, // เพิ่ม rule
      'submittedBy': submittedBy, // เพิ่ม submittedBy
    };
  }
}
