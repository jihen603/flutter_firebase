import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../../../services/aes_helper.dart'; // <- Import du helper

class SensorDashboard extends StatefulWidget {
  const SensorDashboard({Key? key}) : super(key: key);

  @override
  State<SensorDashboard> createState() => _SensorDashboardState();
}

class _SensorDashboardState extends State<SensorDashboard> {
  final dbRef = FirebaseDatabase.instance.ref();

  String humidity = '';
  String temperature = '';
  String soilMoisture = '';
  String gas = '';
  String vibration = '';

  @override
  void initState() {
    super.initState();
    _listenToSensorData();
  }

  void _listenToSensorData() {
    dbRef.child('DHT/humidity').onValue.listen((event) {
      setState(() {
        humidity = decryptAES(event.snapshot.value.toString());
      });
    });

    dbRef.child('DHT/temperature').onValue.listen((event) {
      setState(() {
        temperature = decryptAES(event.snapshot.value.toString());
      });
    });

    dbRef.child('MH-Sensor/soil_moisture').onValue.listen((event) {
      setState(() {
        soilMoisture = decryptAES(event.snapshot.value.toString());
      });
    });

    dbRef.child('MQ5/gas').onValue.listen((event) {
      setState(() {
        gas = decryptAES(event.snapshot.value.toString());
      });
    });

    dbRef.child('SW420/vibration').onValue.listen((event) {
      setState(() {
        vibration = decryptAES(event.snapshot.value.toString());
      });
    });
  }

  Widget _sensorTile(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
        leading: const Icon(Icons.sensors),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Dashboard'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: [
          _sensorTile('Humidité (DHT22)', humidity),
          _sensorTile('Température (DHT22)', temperature),
          _sensorTile('Humidité du sol (MH)', soilMoisture),
          _sensorTile('Gaz (MQ5)', gas),
          _sensorTile('Vibration (SW420)', vibration),
        ],
      ),
    );
  }
}

