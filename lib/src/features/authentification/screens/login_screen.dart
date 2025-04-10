import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:untitled123/src/features/authentification/screens/forget_password/forget_password_options/forget_password_model_bottom_sheet.dart';
import 'package:untitled123/src/features/authentification/screens/signup/signup.dart';
import 'package:untitled123/src/constants/image_strings.dart';
import 'package:untitled123/src/features/authentification/screens/welcome/welcome_screen.dart';
import 'package:untitled123/src/features/authentification/screens/iot%20dashboard/sensordashboardscreen.dart';
import 'package:untitled123/src/features/authentification/screens/AdminDashboard.dart';
import 'package:untitled123/src/features/authentification/screens/update_profile_screen.dart'; // Import UpdateProfileScreen
import '../../../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final String role;

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
                      Row(
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
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
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
                              _showDestinationDialog();
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?", style: TextStyle(color: Colors.white)),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SignUpScreen()),
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      // Ajouter un bouton pour accéder à l'écran de mise à jour du profil
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UpdateProfileScreen()), // Naviguer vers UpdateProfileScreen
                          );
                        },
                        child: const Text(
                          "Update Profile",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  void _showDestinationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/backgroundd.jpg', // Image de fond
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Choose Destination",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Where would you like to go?",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => WelcomeScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                        backgroundColor: Colors.white, // Changed to white
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Welcome", style: TextStyle(fontSize: 18, color: Colors.black)),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SensorDashboard()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                        backgroundColor: Colors.white, // Changed to white
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Sensor Dashboard", style: TextStyle(fontSize: 18, color: Colors.black)),
                    ),
                    const SizedBox(height: 15),
                    if (widget.role == 'Administrator')
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => AdminDashboard()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                          backgroundColor: Colors.white, // Changed to white
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Admin Dashboard", style: TextStyle(fontSize: 18, color: Colors.black)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
