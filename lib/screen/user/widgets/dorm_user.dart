import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/screen/user/screen/detail.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DormScreen extends StatefulWidget {
  const DormScreen({super.key});

  @override
  State<DormScreen> createState() => _DormScreenState();
}

class _DormScreenState extends State<DormScreen> {
  int priceFilterState =
      0; // 0: ไม่มีการกรอง, 1: กรองจากน้อยไปมาก, 2: กรองจากมากไปน้อย
  int ratingFilterState =
      0; // 0: ไม่มีการกรอง, 1: กรองจากน้อยไปมาก, 2: กรองจากมากไปน้อย
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();
  List<String> favorites = [];
  late String userId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid; // กำหนด userId ที่นี่
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              _buildSearchBar(),
              const SizedBox(height: 16),
              // Filter buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilterButton(
                    text: _getPriceFilterText(),
                    icon: _getPriceFilterIcon(),
                    onPressed: () {
                      setState(() {
                        priceFilterState =
                            (priceFilterState + 1) % 3; // เปลี่ยนสถานะ
                      });
                    },
                  ),
                  FilterButton(
                    text: _getRatingFilterText(),
                    icon: _getRatingFilterIcon(),
                    onPressed: () {
                      setState(() {
                        ratingFilterState =
                            (ratingFilterState + 1) % 3; // เปลี่ยนสถานะ
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),
              // StreamBuilder to fetch user favorites
              _buildUserFavorites(),
              const SizedBox(height: 16),
              // StreamBuilder to fetch dormitories
              _buildDormitoryStream(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: searchController,
        decoration: const InputDecoration(
          hintText: 'ค้นหาหอพัก',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.purple),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildUserFavorites() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _getUserFavoritesStream(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasError) {
          return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(child: Text('ไม่พบข้อมูล'));
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        favorites = List<String>.from(userData['favorites'] ?? []);

        return SizedBox.shrink(); // ไม่ต้องแสดงอะไรที่นี่
      },
    );
  }

  Stream<DocumentSnapshot> _getUserFavoritesStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots();
    }
    throw Exception("User not signed in");
  }

  Widget _buildDormitoryStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getDormitoryStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดหอพัก'));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('กำลังโหลด...'));
        }

        if (snapshot.data!.docs.isEmpty) {
          if (searchQuery.isEmpty) {
            return const Center(child: Text('กรุณากรอกข้อมูลค้นหา'));
          } else {
            return const Center(child: Text('ไม่พบหอพักที่ตรงตามเงื่อนไข'));
          }
        }

        return _buildDormitoryList(snapshot.data!.docs, favorites);
      },
    );
  }

  Stream<QuerySnapshot> _getDormitoryStream() {
    CollectionReference dormitoryCollection =
        FirebaseFirestore.instance.collection('dormitories');

    Query query = dormitoryCollection;

    // กรองตามคำค้นหา
    if (searchQuery.isNotEmpty) {
      query = query
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThanOrEqualTo: '$searchQuery\uf8ff');
    }

    // เรียงตามราคา หรือ คะแนน ตามที่เลือก
    if (priceFilterState == 1) {
      query = query.orderBy('price', descending: false); // กรองจากน้อยไปมาก
    } else if (priceFilterState == 2) {
      query = query.orderBy('price', descending: true); // กรองจากมากไปน้อย
    }

    if (ratingFilterState == 1) {
      query = query.orderBy('rating', descending: false); // กรองจากน้อยไปมาก
    } else if (ratingFilterState == 2) {
      query = query.orderBy('rating', descending: true); // กรองจากมากไปน้อย
    }

    return query.snapshots();
  }

  Widget _buildDormitoryList(
      List<QueryDocumentSnapshot> dorms, List<String> favorites) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dorms.length,
      itemBuilder: (context, index) {
        var dorm = dorms[index];
        String dormId = dorm.id;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _buildDormitoryCard(dorm, dormId, favorites),
        );
      },
    );
  }

  Widget _buildDormitoryCard(
      QueryDocumentSnapshot dorm, String dormId, List<String> favorites) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 241, 229, 255),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dorm image
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              image: DecorationImage(
                image: NetworkImage(dorm['imageUrl']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dorm['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('ราคา ${dorm['price']} บาท',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('คะแนน ${dorm['rating']}/5',
                    style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // View details button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DormallDetailScreen(dormId: dormId),
                          ),
                        );
                      },
                      child: const Text('ดูรายละเอียด'),
                    ),
                    // Favorite heart icon
                    IconButton(
                      icon: Icon(
                        favorites.contains(dormId)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.pink,
                      ),
                      onPressed: () async {
                        await _toggleFavorite(dormId);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite(String dormId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      final userData = await userDoc.get();
      if (userData.exists) {
        List<String> favorites =
            List<String>.from(userData.data()!['favorites'] ?? []);
        if (favorites.contains(dormId)) {
          favorites.remove(dormId);
        } else {
          favorites.add(dormId);
        }
        await userDoc.update({'favorites': favorites});
      }
    }
  }

  String _getPriceFilterText() {
    switch (priceFilterState) {
      case 1:
        return 'กรองจากน้อยไปมาก'; // สถานะกรองน้อยไปมาก
      case 2:
        return 'กรองจากมากไปน้อย'; // สถานะกรองมากไปน้อย
      default:
        return 'กรองราคา'; // สถานะเริ่มต้น
    }
  }

// ฟังก์ชันเพื่อคืนค่าข้อความสำหรับกรองคะแนน
  String _getRatingFilterText() {
    switch (ratingFilterState) {
      case 1:
        return 'กรองจากน้อยไปมาก'; // สถานะกรองน้อยไปมาก
      case 2:
        return 'กรองจากมากไปน้อย'; // สถานะกรองมากไปน้อย
      default:
        return 'กรองคะแนน'; // สถานะเริ่มต้น
    }
  }

  Icon _getPriceFilterIcon() {
    switch (priceFilterState) {
      case 1:
        return const Icon(Icons.arrow_upward); // น้อยไปมาก
      case 2:
        return const Icon(Icons.arrow_downward); // มากไปน้อย
      default:
        return const Icon(Icons.filter_list); // สถานะเริ่มต้น
    }
  }

  // ฟังก์ชันเพื่อคืนค่า Icon สำหรับกรองคะแนน
  Icon _getRatingFilterIcon() {
    switch (ratingFilterState) {
      case 1:
        return const Icon(Icons.arrow_upward); // น้อยไปมาก
      case 2:
        return const Icon(Icons.arrow_downward); // มากไปน้อย
      default:
        return const Icon(Icons.filter_list); // สถานะเริ่มต้น
    }
  }
}

class FilterButton extends StatelessWidget {
  final String text;
  final Icon icon;
  final VoidCallback onPressed;

  const FilterButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8), // เพิ่มระยะห่างระหว่างไอคอนและข้อความ
          Text(text),
        ],
      ),
    );
  }
}
