import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled123/src/constants/image_strings.dart';

class UpdateProfileScreen extends StatefulWidget {
  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentEmailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  Future<bool> _reauthenticateUser() async {
    try {
      User? user = _auth.currentUser;
      AuthCredential credential = EmailAuthProvider.credential(
        email: _currentEmailController.text,
        password: _currentPasswordController.text,
      );
      await user?.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      _showSnackbar("Re-authentication failed: ${e.toString()}");
      return false;
    }
  }

  Future<void> _updateEmail() async {
    if (!_formKey.currentState!.validate()) return;
    if (!await _reauthenticateUser()) return;
    try {
      await _auth.currentUser?.verifyBeforeUpdateEmail(_newEmailController.text);
      _showSnackbar("A confirmation email has been sent!");
    } catch (e) {
      _showSnackbar("Error: ${e.toString()}");
    }
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (!await _reauthenticateUser()) return;
    try {
      await _auth.currentUser?.updatePassword(_newPasswordController.text);
      _showSnackbar("Password updated successfully!");
    } catch (e) {
      _showSnackbar("Error: ${e.toString()}");
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            tSplashTopImage,
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Update Profile",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Modify your email and password securely",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _buildTextField("Current Email", Icons.email, _currentEmailController, false),
                      _buildTextField("Current Password", Icons.lock, _currentPasswordController, true),
                      _buildTextField("New Email", Icons.email_outlined, _newEmailController, false),
                      _buildTextField("New Password", Icons.lock_outline, _newPasswordController, true),
                      const SizedBox(height: 20),
                      _buildButton("Update Email", _updateEmail),
                      const SizedBox(height: 12),
                      _buildButton("Update Password", _updatePassword),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Back", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hintText, IconData icon, TextEditingController controller, bool isPassword) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey[700]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "$hintText cannot be empty";
          if (!isPassword && !emailRegex.hasMatch(value)) {
            return "Enter a valid email";
          }
          if (isPassword && value.length < 6) return "Password must be at least 6 characters";
          return null;
        },
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent, // Make the background transparent
        side: BorderSide(color: Colors.blueAccent), // Border color
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0, // Remove shadow to make it flat
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.blueAccent, // Text color
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
