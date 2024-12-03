import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServiceUser {
  Stream<DocumentSnapshot> getUserStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();
  }

  Future<DocumentSnapshot> getUserData(String userId) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
  }

  Future<void> updateUserData (String userId, Map<String, dynamic> data) async {
    try {
      
    await FirebaseFirestore.instance
           .collection('users')
           .doc(userId)
           .update(data);
    } catch (e) {
      print(e);
    }
  }
  
  // อัปเดตข้อมูลหอพักหลังการจอง
  Future<void> updateDormitoryBooking(String dormitoryId, String userId,
      int availableRooms, String chatRoomId) async {
    try {
      await FirebaseFirestore.instance
          .collection('dormitories')
          .doc(dormitoryId)
          .update({
        'availableRooms': availableRooms - 1,
        'usersBooked': FieldValue.arrayUnion([userId]),
        'chatRoomId': FieldValue.arrayUnion([chatRoomId]),
      });
    } catch (e) {
      print('Error updating dormitory booking: $e');
    }
  }

  // อัปเดตข้อมูลผู้ใช้หลังการจอง
  Future<void> updateUserBooking(String userId, String dormitoryId,
      String chatRoomId, String chatGroupId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'bookedDormitory': dormitoryId,
        'chatRoomId': FieldValue.arrayUnion([chatRoomId]),
        'chatGroupId': chatGroupId,
      });
    } catch (e) {
      print('Error updating user booking: $e');
    }
  }

  // สร้างข้อมูลห้องแชทใน chatRooms
  Future<void> createChatRoom(
      String chatRoomId, String userId, String dormitoryId) async {
    try {
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .set({
        'participants': [userId, dormitoryId],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating chat room: $e');
    }
  }

  // เพิ่มการแจ้งเตือนการจองใน notifications
  Future<void> addBookingNotification(String userId, String dormitoryId) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'dormitoryId': dormitoryId,
        'type': 'booking',
        'message': 'การจองหอพักสำเร็จ',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'unread',
      });
    } catch (e) {
      print('Error adding notification: $e');
    }
  }

  // อัปเดตข้อมูลการแจ้งเตือนในผู้ใช้
  Future<void> updateUserNotifications(
      String userId, String dormitoryId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'notifications': FieldValue.arrayUnion([
          {
            'dormitoryId': dormitoryId,
            'type': 'booking',
            'timestamp': FieldValue.serverTimestamp(),
          }
        ]),
      });
    } catch (e) {
      print('Error updating user notifications: $e');
    }
  }

  Future<void> addReview({
    required String dormitoryId,
    required String userId,
    required String text,
    required double rating,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('reviews').add({
        'dormId': dormitoryId,
        'user': dormitoryId,
        'date': DateTime.now().toIso8601String(),
        'text': text,
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error adding review: $e');
    }
  }

  // ignore: unused_element
  Future<void> updateDormitoryReviews(String dormId) async {
    try {
      // ดึงข้อมูลรีวิวของหอพัก
      QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('dormId', isEqualTo: dormId)
          .get();

      int reviewCount = reviewsSnapshot.size;
      double totalRating = 0.0;

      for (var doc in reviewsSnapshot.docs) {
        totalRating +=
            (doc.data() as Map<String, dynamic>)['rating']?.toDouble() ?? 0.0;
      }

      // คำนวณค่าเฉลี่ยคะแนน (เก็บเป็น double)
      double averageRating = reviewCount > 0 ? totalRating / reviewCount : 0.0;

      // อัปเดตข้อมูลใน Firestore
      await FirebaseFirestore.instance
          .collection('dormitories')
          .doc(dormId)
          .update({
        'reviewCount': reviewCount,
        'rating': averageRating,
      });
    } catch (e) {
      print('Error updating dormitory reviews: $e');
      throw Exception('Failed to update dormitory reviews.');
    }
  }
}
