import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("sensors");

  void listenForEncryptedData(Function(String) onDataReceived) {
    dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null && data.containsKey("encrypted_data")) {
        onDataReceived(data["encrypted_data"]);
      }
    });
  }
}
