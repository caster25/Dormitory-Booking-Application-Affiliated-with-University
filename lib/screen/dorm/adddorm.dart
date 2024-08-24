import 'package:dorm_app/screen/homepage.dart';
import 'package:flutter/material.dart';

class AddDorm extends StatefulWidget {
  const AddDorm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddDormState createState() => _AddDormState();
}

class _AddDormState extends State<AddDorm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController dormNameController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();


  void clearForm() {
    dormNameController.clear();
    ownerNameController.clear();
    contactController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('กรอกข้อมูลหอพัก'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ชื่อหอพัก', style: TextStyle(fontSize: 20)),
                TextFormField(
                  controller: dormNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกชื่อหอพัก';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                const Text('ชื่อเจ้าของหอพัก', style: TextStyle(fontSize: 20)),
                TextFormField(
                  controller: ownerNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกชื่อเจ้าของหอพัก';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                const Text('ช่องทางติดต่อ', style: TextStyle(fontSize: 20)),
                TextFormField(
                  controller: contactController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกช่องทางติดต่อ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                const Text('เพิ่มรูปหอพัก', style: TextStyle(fontSize: 20)),
                ElevatedButton(
                  onPressed: () {
                    // Add image picker functionality here
                  },
                  child: const Text('เพิ่มรูปภาพ'),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return const Homepage();
                        }));
                        // Save the dorm info

                        clearForm();
                      }
                    },
                    child: const Text('บันทึกข้อมูล'),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return const Homepage();
                    }));
                  }, child: const Text('TEst')),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

