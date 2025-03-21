import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Ajoutez l'import ici
import '../../../constants/image_strings.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isAddingOperator = false;

  // Fonction pour supprimer un opérateur avec confirmation
  void _deleteOperator(BuildContext context, String operatorId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Operator"),
        content: const Text("Are you sure you want to remove this operator?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('operators').doc(operatorId).delete();
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Fonction pour ajouter un nouvel opérateur
  void _addOperator() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        // Créer l'utilisateur dans Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Si la création de l'utilisateur est réussie, ajouter les données dans Firestore
        await FirebaseFirestore.instance.collection('operators').add({
          'email': email,
          'password': password, // Vous pouvez ajouter un hachage ici pour plus de sécurité
          'lastSignIn': FieldValue.serverTimestamp(),
        });

        // Réinitialiser les champs et cacher le formulaire d'ajout
        _emailController.clear();
        _passwordController.clear();
        setState(() {
          _isAddingOperator = false;
        });

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add operator.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard - Operators'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image de fond flou
          Image.asset(
            tSplashTopImage, // Assurez-vous d'avoir l'image appropriée
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
          // Contenu principal
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Operator Connections',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('operators').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No operators found.', style: TextStyle(color: Colors.white)));
                      }
                      return ListView(
                        children: snapshot.data!.docs.map((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: const Icon(Icons.person, color: Colors.black, size: 40),
                              title: Text(
                                data['email'] ?? 'Unknown',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text("Last Sign-In: ${data['lastSignIn']?.toDate() ?? 'Never'}"),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteOperator(context, doc.id),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                if (_isAddingOperator)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter operator email',
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter operator password',
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _addOperator,
                          child: const Text('Add Operator'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,  // Correction ici
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isAddingOperator = false;
                            });
                          },
                          child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isAddingOperator = !_isAddingOperator;
          });
        },
        backgroundColor: Colors.white,
        child: Icon(_isAddingOperator ? Icons.cancel : Icons.add, color: Colors.black),
      ),
    );
  }
}

