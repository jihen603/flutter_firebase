// lib/services/database_service.dart
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  // Méthode pour récupérer les données en temps réel
  Stream<DatabaseEvent> getRealTimeData(String path) {
    return _databaseRef.child(path).onValue;
  }
}
