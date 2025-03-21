import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled123/src/constants/image_strings.dart';
import 'package:untitled123/src/features/authentification/screens/signup/signup.dart';
import 'package:untitled123/src/features/authentification/screens/forget_password/forget_password_options/forget_password_model_bottom_sheet.dart';
import '../../../../services/auth_service.dart';
import 'update_profile_screen.dart'; // Importation de la nouvelle page

class LoginScreen extends StatefulWidget {
  final String role; // Déclaration du rôle

  const LoginScreen({Key? key, required this.role}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Welcome Back (${widget.role})",
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Please Login Here",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      _buildEmailField(),
                      const SizedBox(height: 20),
                      _buildPasswordField(),
                      const SizedBox(height: 10),
                      _buildRememberMeAndForgotPassword(),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            bool success = await AuthService().login(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                              context: context,
                              role: widget.role,
                            );

                            if (success) {
                              // Mise à jour `lastSignIn` uniquement pour les opérateurs
                              if (widget.role == 'Operator') {
                                // Met à jour la date et l'heure de la dernière connexion de l'opérateur
                                await FirebaseFirestore.instance
                                    .collection('operators')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .update({'lastSignIn': FieldValue.serverTimestamp()});
                              }

                              // Redirige l'utilisateur vers la page de bienvenue ou le tableau de bord
                              Navigator.pushReplacementNamed(context, '/welcome');
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Sign In", style: TextStyle(color: Colors.black, fontSize: 18)),
                      ),
                      const SizedBox(height: 20),
                      if (widget.role == 'Administrator') ...[
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/adminDashboard');
                          },
                          child: const Text(
                            "Go to Admin Dashboard",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?", style: TextStyle(color: Colors.white)),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                            },
                            child: const Text("Sign Up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateProfileScreen()));
                        },
                        child: const Text(
                          "Update Profile",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
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

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        hintText: "Email",
        prefixIcon: const Icon(Icons.email, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Email cannot be empty';
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Enter a valid email';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        hintText: "Password",
        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Password cannot be empty' : null,
    );
  }

  Widget _buildRememberMeAndForgotPassword() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) => setState(() => _rememberMe = value!),
        ),
        const Text("Remember me", style: TextStyle(color: Colors.white)),
        const Spacer(),
        TextButton(
          onPressed: () {
            ForgetPasswordScreen.buildShowModalBottomSheet(context);
          },
          child: const Text("Forgot Password?", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

