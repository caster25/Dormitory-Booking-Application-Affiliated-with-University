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
  bool isPriceAscending = true;
  bool isRatingAscending = true;
  String sortBy = 'price';
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

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
              _buildFilterButtons(),
              const SizedBox(height: 16),
              // FutureBuilder to fetch user favorites
              _buildUserFavoritesFutureBuilder(),
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

  Widget _buildFilterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        FilterButton(
          text: 'ราคา/เทอม',
          onPressed: () {
            setState(() {
              sortBy = 'price';
              isPriceAscending = !isPriceAscending;
            });
          },
          isSelected: sortBy == 'price',
        ),
        FilterButton(
          text: 'ให้คะแนน',
          onPressed: () {
            setState(() {
              sortBy = 'rating';
              isRatingAscending = !isRatingAscending;
            });
          },
          isSelected: sortBy == 'rating',
        ),
      ],
    );
  }

  Widget _buildUserFavoritesFutureBuilder() {
    return FutureBuilder<DocumentSnapshot>(
      future: _getUserFavorites(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userSnapshot.hasError) {
          return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(child: Text('ไม่พบข้อมูล'));
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        final favorites = List<String>.from(userData['favorites'] ?? []);

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('dormitories')
              .where('name', isGreaterThanOrEqualTo: searchQuery.isNotEmpty ? searchQuery : null)
              .where('name', isLessThanOrEqualTo: searchQuery.isNotEmpty ? '$searchQuery\uf8ff' : null)
              .orderBy(sortBy, descending: sortBy == 'price' ? !isPriceAscending : !isRatingAscending)
              .snapshots(),

          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดหอพัก'));
            }


            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('กำลังโหลด'));
            }

            return _buildDormitoryList(snapshot.data!.docs, favorites);
          },
        );
      },
    );
  }

  Widget _buildDormitoryList(List<QueryDocumentSnapshot> dorms, List<String> favorites) {
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

  Widget _buildDormitoryCard(QueryDocumentSnapshot dorm, String dormId, List<String> favorites) {
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
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
                Text(dorm['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('ราคา ${dorm['price']} บาท', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('คะแนน ${dorm['rating']}/5', style: const TextStyle(color: Colors.red)),
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
                            builder: (context) => DormallDetailScreen(dormId: dormId),
                          ),
                        );
                      },
                      child: const Text('ดูรายละเอียด'),
                    ),
                    // Favorite heart icon
                    IconButton(
                      icon: Icon(
                        favorites.contains(dormId) ? Icons.favorite : Icons.favorite_border,
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

  Future<DocumentSnapshot> _getUserFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    }
    throw Exception("User not signed in");
  }

  Future<void> _toggleFavorite(String dormId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final userFavoritesRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    DocumentSnapshot userDoc = await userFavoritesRef.get();

    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      List<dynamic> currentFavorites = List.from(userData['favorites'] ?? []);

      // Toggle favorite status
      if (currentFavorites.contains(dormId)) {
        currentFavorites.remove(dormId);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from favorites')));
      } else {
        currentFavorites.add(dormId);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to favorites')));
      }

      // Update favorites in Firestore
      await userFavoritesRef.update({'favorites': currentFavorites});
    } else {
      // Create user document with favorite dormitory
      await userFavoritesRef.set({'favorites': [dormId]});
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to favorites')));
    }

    // Rebuild to reflect changes
    setState(() {});
  }
}

class FilterButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSelected;

  const FilterButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.purple : Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}
