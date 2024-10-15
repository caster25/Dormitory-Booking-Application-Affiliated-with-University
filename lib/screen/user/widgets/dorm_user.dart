import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/screen/user/screen/detail.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DormScreen extends StatefulWidget {
  const DormScreen({super.key});

  @override
  State<DormScreen> createState() => _DormScreenState();
}

class _DormScreenState extends State<DormScreen> {
  String selectedFilterType = '';
  int filterState = 0;
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();
  List<String> favorites = [];
  late String userId;
  bool isSearching = false; // ตัวแปรสำหรับตรวจสอบสถานะการค้นหา
  bool isFiltering = false; // ตัวแปรสำหรับตรวจสอบสถานะการกรอง
  final formatNumber = NumberFormat('#,##0');

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
    }
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.purple,
          width: 2.0,
        ),
      ),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'ค้นหาหอพัก',
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: Colors.purple),
          suffixIcon: isSearching // เพิ่มไอคอนยกเลิกในช่องค้นหา
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      isSearching = false;
                      searchController.clear();
                      searchQuery = '';
                    });
                  },
                )
              : null,
        ),
        onTap: () {
          setState(() {
            isSearching = true;
            isFiltering = false;
          });
        },
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Spacer(),
        DropdownButton<String>(
          value: selectedFilterType.isEmpty ? null : selectedFilterType,
          hint: const Text('เลือกการกรอง'),
          onTap: () {
            setState(() {
              isFiltering = true;
              isSearching = false;
            });
          },
          items: const [
            DropdownMenuItem(
              value: 'price',
              child: Text('กรองตามราคา'),
            ),
            DropdownMenuItem(
              value: 'rating',
              child: Text('กรองตามคะแนน'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              selectedFilterType = value!;
              filterState = 0;
            });
          },
        ),
        if (selectedFilterType.isNotEmpty) ...[
          const SizedBox(width: 8),
          FilterButton(
            text: _getFilterText(),
            icon: _getFilterIcon().icon!,
            onPressed: () {
              setState(() {
                filterState = (filterState + 1) % 3;
              });
            },
          ),
        ],
        if (isFiltering) // เพิ่มปุ่มยกเลิกการกรอง
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              setState(() {
                isFiltering = false;
                selectedFilterType = '';
                filterState = 0;
              });
            },
          ),
      ],
    );
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
              // แสดงช่องค้นหาหรือช่องกรองอย่างใดอย่างหนึ่งเท่านั้น
              if (!isFiltering) _buildSearchBar(),
              if (!isSearching) _buildFilterSection(),

              const SizedBox(height: 8),
              const SizedBox(height: 16),
              _buildUserFavorites(),
              const SizedBox(height: 16),
              _buildDormitoryStream(),
            ],
          ),
        ),
      ),
    );
  }

  String _getFilterText() {
    switch (filterState) {
      case 1:
        return selectedFilterType == 'price'
            ? 'เรียงตามราคา: สูงไปต่ำ'
            : 'เรียงตามคะแนน: สูงไปต่ำ';
      case 2:
        return selectedFilterType == 'price'
            ? 'เรียงตามราคา: ต่ำไปสูง'
            : 'เรียงตามคะแนน: ต่ำไปสูง';
      default:
        return selectedFilterType == 'price' ? 'กรองตามราคา' : 'กรองตามคะแนน';
    }
  }

  Icon _getFilterIcon() {
    switch (filterState) {
      case 1:
        return const Icon(Icons.arrow_downward);
      case 2:
        return const Icon(Icons.arrow_upward);
      default:
        return const Icon(Icons.filter_list);
    }
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

    if (selectedFilterType == 'price') {
      query = query.orderBy('price', descending: filterState == 1);
    } else if (selectedFilterType == 'rating') {
      query = query.orderBy('rating', descending: filterState == 1);
    }

    return query.snapshots();
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

        return const SizedBox.shrink();
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
          return const Center(
              child:
                  CircularProgressIndicator()); // เปลี่ยนเป็น CircularProgressIndicator
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
    bool isFavorite = favorites.contains(dormId); // ตรวจสอบสถานะของหัวใจ
    List<dynamic> images = dorm['imageUrl']; // ดึง list ของรูปภาพ

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 241, 229, 255),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dorm images - ดึงรูปแรกจาก list
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              image: DecorationImage(
                image: NetworkImage(images.isNotEmpty
                    ? images[0]
                    : ''), // ใช้รูปแรกใน list หรือใช้ '' หากไม่มีรูป
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${dorm['name']} (${dorm['dormType']} ${dorm['roomType']}) ',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('ราคา ${formatNumber.format(dorm['price'])} บาท',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  dorm['rating'] != null && dorm['rating'] > 0
                      ? 'คะแนน ${dorm['rating']?.toStringAsFixed(0) ?? '0'}/5'
                      : 'ยังไม่มีการรีวิว',
                  style: const TextStyle(color: Colors.red),
                ),
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
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.pink : Colors.grey,
                      ),
                      onPressed: () async {
                        // เปลี่ยนสถานะของหัวใจที่ UI และฐานข้อมูล
                        await _toggleFavorite(dormId);
                        setState(() {}); // อัปเดต UI
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

      final userSnapshot = await userDoc.get();
      if (userSnapshot.exists) {
        List<dynamic> favoritesList = userSnapshot['favorites'] ?? [];
        if (favoritesList.contains(dormId)) {
          favoritesList.remove(dormId); // ลบหอพักออกจากรายการโปรด
        } else {
          favoritesList.add(dormId); // เพิ่มหอพักเข้ารายการโปรด
        }

        await userDoc.update({'favorites': favoritesList});
      }
    }
  }
}

class FilterButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const FilterButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: const Color.fromARGB(255, 224, 224, 224),
      ),
    );
  }
}
