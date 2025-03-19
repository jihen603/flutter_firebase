import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manageOperatorsScreen.dart';
import 'manageUserRolesScreen.dart';

// Page principale du tableau de bord Admin
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to the Admin Dashboard',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildStatisticCard('Total Users', '1200', Icons.people),
            const SizedBox(height: 10),
            _buildStatisticCard('Active Devices', '85', Icons.devices),
            const SizedBox(height: 10),
            _buildStatisticCard('Alerts', '15', Icons.warning),
            const SizedBox(height: 20),
            const Text(
              'Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildActionCard('Manage Operators', Icons.supervised_user_circle, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageOperatorsScreen()),
              );
            }),
            const SizedBox(height: 10),
            _buildActionCard('Manage User Roles', Icons.rule, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageUserRolesScreen()),
              );
            }),
            const SizedBox(height: 10),
            _buildActionCard('View Reports', Icons.report, () {
              // Ajouter une fonctionnalité pour les rapports
            }),
          ],
        ),
      ),
    );
  }

  // Widget pour une carte de statistique
  Widget _buildStatisticCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.blueAccent),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(value, style: const TextStyle(fontSize: 20)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour une carte d'action
  Widget _buildActionCard(String title, IconData icon, VoidCallback onPressed) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        onTap: onPressed,
      ),
    );
  }
}
