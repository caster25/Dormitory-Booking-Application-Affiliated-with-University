import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/common/res/colors.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:dorm_app/features/screen/user/screen/detail.dart';
import 'package:dorm_app/features/screen/user/utils/filter_button.dart';
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
  bool isSearching = false;
  bool isFiltering = false;
  final formatNumber = NumberFormat('#,##0');
   List<String> dormitories = [];
  List<String> filteredDormitories = [];

  @override
  void initState() {
    super.initState();
    filteredDormitories = dormitories; // กำหนดค่าเริ่มต้นให้แสดงทั้งหมด
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
    }
  }

  void filterDormitories() {
    setState(() {
      filteredDormitories = dormitories
          .where((dorm) => dorm.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ColorsApp.primary01,
          width: 2.0,
        ),
      ),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'ค้นหาหอพัก',
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: ColorsApp.primary01),
          suffixIcon: isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      isSearching = false;
                      searchController.clear();
                      searchQuery = '';
                      filteredDormitories = dormitories; 
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
          filterDormitories(); // เรียกใช้ฟังก์ชันกรองเมื่อพิมพ์
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end, // จัดตำแหน่งไปที่ด้านขวา
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end, // จัดแนวในแนวนอนให้ชิดขวา
          children: [
            DropdownButton<String>(
              value: selectedFilterType.isEmpty ? null : selectedFilterType,
              hint: TextWidget.buildSection14('เลือกการกรอง'),
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
              const SizedBox(height: 8),
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end, // จัดแนวให้ชิดขวา
            children: [
              // แสดงช่องค้นหาหรือช่องกรองอย่างใดอย่างหนึ่งเท่านั้น
              if (!isFiltering) _buildSearchBar(),
              if (!isSearching) _buildFilterSection(),
              const SizedBox(height: 16),
              _buildUserFavorites(),
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
          padding: const EdgeInsets.all(8),
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
      child: Card(
        margin: const EdgeInsets.all(1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                images.isNotEmpty ? images[0] : '',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 100),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ชื่อและรายละเอียดหอพัก
                  TextWidget.buildSection18(
                    '${dorm['name']} (${dorm['dormType']} ${dorm['roomType']})',
                  ),
                  const SizedBox(height: 4),
                  TextWidget.buildSubSectionBold16(
                    'ราคา: ${formatNumber.format(dorm['price'])} บาท',
                  ),
                  TextWidget.buildSubSectionRed16(
                    dorm['rating'] != null && dorm['rating'] > 0
                        ? 'คะแนน ${dorm['rating'].toStringAsFixed(1)}/5'
                        : 'ยังไม่มีการรีวิว',
                  ),
                  const SizedBox(height: 4),
                  TextWidget.buildSection16(
                    'ห้องว่าง ${dorm['availableRooms']} ห้อง',
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                        child: TextWidget.buildSubSection16('ดูรายละเอียด'),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.pink : Colors.grey,
                        ),
                        onPressed: () async {
                          await _toggleFavorite(dormId);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
