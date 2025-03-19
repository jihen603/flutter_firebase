import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUserRolesScreen extends StatelessWidget {
  const ManageUserRolesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Exemple de liste d'utilisateurs
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage User Roles'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userId = user.id;
              final userName = user['name'];
              final userRole = user['role'];

              return ListTile(
                title: Text(userName),
                subtitle: Text('Role: $userRole'),
                trailing: PopupMenuButton<String>(
                  onSelected: (role) {
                    _updateUserRole(userId, role);
                  },
                  itemBuilder: (BuildContext context) {
                    return ['Admin', 'Operator'].map((String role) {
                      return PopupMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Mise à jour du rôle de l'utilisateur dans Firestore
  void _updateUserRole(String userId, String newRole) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'role': newRole,
      });
    } catch (e) {
      print("Erreur lors de la mise à jour du rôle: $e");
    }
  }
}
