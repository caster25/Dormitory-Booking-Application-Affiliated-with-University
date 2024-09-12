import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dorm_app/screen/login.dart';
import 'package:dorm_app/model/Userprofile.dart'; // Assuming this contains the UserProfile class

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _userfnameController = TextEditingController();
  final TextEditingController _userlnameController = TextEditingController();
  final TextEditingController _numphoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _acceptTerms = false;
  bool _isOwner = false; // Add this to distinguish between user and owner

  final auth = FirebaseAuth.instance;
  final usersCollection = FirebaseFirestore.instance.collection('users');

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please accept the terms and conditions')),
        );
        return;
      }

      try {
        UserCredential userCredential =
            await auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        var currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final userProfile = UserProfile(
            idusers: currentUser.uid, // Use String type for iduser
            email: _emailController.text,
            firstname: _userfnameController.text,
            lastname: _userlnameController.text,
            numphone: _numphoneController.text,
            role: _isOwner ? 'owner' : 'user',
          );

          // Save user profile to Firestore
          await usersCollection.doc(currentUser.uid).set(userProfile.toMap());

          _formKey.currentState!.reset();
          _passwordController.clear();
          _confirmPasswordController.clear();
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // ignore: use_build_context_synchronously
          _showErrorDialog(context,
              'This email is already in use. Please use another email.');
        } else {
          // ignore: use_build_context_synchronously
          _showErrorDialog(context, 'Registration error: ${e.message}');
        }
      } catch (e) {
        // ignore: use_build_context_synchronously
        _showErrorDialog(context, 'Error: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please check your information again')),
      );
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Column(
                      children: [
                        Text('Create New Account',
                            style: TextStyle(fontSize: 40)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: _userfnameController,
                  decoration: _buildInputDecoration('First Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: _userlnameController,
                  decoration: _buildInputDecoration('Last Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: _numphoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _buildInputDecoration('Phone Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Invalid phone number format';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration('Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Invalid email format';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _buildInputDecoration('Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: _buildInputDecoration('Confirm Password'),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value!;
                        });
                      },
                    ),
                    const Text(
                      'I accept the terms and conditions',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Checkbox(
                      value: _isOwner,
                      onChanged: (value) {
                        setState(() {
                          _isOwner = value!;
                        });
                      },
                    ),
                    const Text(
                      'Register as Owner',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _register,
                    child:
                        const Text('Register', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(height: 25),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Already have an account? Log in',
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
