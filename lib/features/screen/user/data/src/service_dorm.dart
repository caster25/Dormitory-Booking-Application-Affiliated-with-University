import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServiceDorm {
  Future<DocumentSnapshot> getOwnerDataOnce(String dormId) async {
    return await FirebaseFirestore.instance
        .collection('dormitories')
        .doc(dormId)
        .get();
  }

  Future<void> updateDormitory(String dormId, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection('dormitories')
        .doc(dormId)
        .update(data);
  }

  Stream<DocumentSnapshot> getDormData(String dormId) {
    return FirebaseFirestore.instance
        .collection('dormitories')
        .doc(dormId)
        .snapshots();
  }

  Future<DocumentSnapshot> getDormCurrent(String currentDormitoryId) async {
    try {
      DocumentSnapshot dormitoryDoc = await FirebaseFirestore.instance
          .collection('dormitories')
          .doc(currentDormitoryId)
          .get();

      // Check if the document exists
      if (dormitoryDoc.exists) {
        return dormitoryDoc; // Return the document if it exists
      } else {
        throw Exception('Dormitory not found!');
      }
    } catch (e) {
      print('Error fetching dormitory data: $e');
      throw Exception('Failed to load dormitory data');
    }
  }
}
