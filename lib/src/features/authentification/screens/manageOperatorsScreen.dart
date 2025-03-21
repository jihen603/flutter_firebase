import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageOperatorsScreen extends StatefulWidget {
  const ManageOperatorsScreen({Key? key}) : super(key: key);

  @override
  _ManageOperatorsScreenState createState() => _ManageOperatorsScreenState();
}

class _ManageOperatorsScreenState extends State<ManageOperatorsScreen> {
  final TextEditingController _newOperatorController = TextEditingController();

  @override
  void dispose() {
    _newOperatorController.dispose();
    super.dispose();
  }

  // Ajouter un opérateur
  void _addOperator() async {
    final operatorName = _newOperatorController.text.trim();
    if (operatorName.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('operators').add({
          'name': operatorName,
          'createdAt': FieldValue.serverTimestamp(),
          'lastSignIn': null,
        });
        _newOperatorController.clear();
      } catch (e) {
        print("Erreur lors de l'ajout de l'opérateur: $e");
      }
    }
  }

  // Supprimer un opérateur
  void _removeOperator(String operatorId) async {
    try {
      await FirebaseFirestore.instance.collection('operators').doc(operatorId).delete();
    } catch (e) {
      print("Erreur lors de la suppression de l'opérateur: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Operators'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage Operators',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _newOperatorController,
              decoration: const InputDecoration(
                labelText: 'Enter Operator Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addOperator,
              child: const Text('Add Operator'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            ),
            const SizedBox(height: 20),
            const Text(
              'Existing Operators',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('operators').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final operators = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: operators.length,
                    itemBuilder: (context, index) {
                      final operator = operators[index];
                      final operatorId = operator.id;
                      final operatorName = operator['name'];
                      final lastSignIn = operator['lastSignIn'] != null
                          ? (operator['lastSignIn'] as Timestamp).toDate().toString()
                          : 'Never logged in';
                      return Card(
                        child: ListTile(
                          title: Text(operatorName),
                          subtitle: Text('Last Sign-In: $lastSignIn'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeOperator(operatorId),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
