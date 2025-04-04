import 'package:firebase_database/firebase_database.dart';
import 'aes_helper.dart';

class IotDataFirebase {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Stream<Map<String, dynamic>> getRealTimeData({String? deviceType}) {
    return _dbRef.child(deviceType ?? 'Arduino').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return {
        'temperature': _parseValue(data['DHT']?['temperature']),
        'humidity': _parseValue(data['DHT']?['humidity']),
        'gas': _parseValue(data['MQ5']?['gas']),
        'vibration': _parseBool(data['SW420']?['vibration']),
        'soil_moisture': _parseValue(data['Soil']?['moisture']),
      };
    });
  }

  Future<bool> testConnection() async {
    try {
      final snapshot = await _dbRef.child('Arduino').once();
      return snapshot.snapshot.exists;
    } catch (e) {
      return false;
    }
  }

  double _parseValue(dynamic encrypted, {String? customKey}) {
    if (encrypted == null) return 0.0;
    final decrypted = AESHelper.decryptIotData(
      encrypted.toString(),
      customKey: customKey,
    );
    return double.tryParse(decrypted) ?? 0.0;
  }

  bool _parseBool(dynamic encrypted, {String? customKey}) {
    if (encrypted == null) return false;
    final decrypted = AESHelper.decryptIotData(
      encrypted.toString(),
      customKey: customKey,
    );
    return decrypted == '1' || decrypted.toLowerCase() == 'true';
  }
}