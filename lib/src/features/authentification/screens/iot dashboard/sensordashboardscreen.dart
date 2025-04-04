import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Ajoutez ce package si ce n'est pas déjà fait

import '../../../../../services/aes_helper.dart';
import '../../../../../services/iot_data_firebase.dart'; // Importez votre service

class SensorDataPage extends StatefulWidget {
  @override
  _SensorDataPageState createState() => _SensorDataPageState();
}

class _SensorDataPageState extends State<SensorDataPage> {
  Map<String, dynamic> _sensorData = {
    'temperature': 0.0,
    'humidity': 0.0,
    'gas': 0.0,
    'vibration': false,
  };

  StreamSubscription? _dataSubscription;

  @override
  void initState() {
    super.initState();
    // Accéder au service via Provider
    final iotDataService = Provider.of<IotDataFirebase>(context, listen: false);
    _setupRealTimeListener(iotDataService);
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    super.dispose();
  }

  void _setupRealTimeListener(IotDataFirebase iotDataService) {
    _dataSubscription = iotDataService.realTimeDecryptedData.listen((data) {
      setState(() {
        _sensorData = {
          'temperature': data['temperature'],
          'humidity': data['humidity'],
          'gas': data['gas'],
          'vibration': data['vibration'] == 1.0, // Conversion en booléen
        };
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Données des Capteurs en Temps Réel'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSensorCard(
              icon: Icons.thermostat,
              title: 'Température',
              value: '${_sensorData['temperature'].toStringAsFixed(1)} °C',
              color: Colors.blue,
            ),
            _buildSensorCard(
              icon: Icons.water_drop,
              title: 'Humidité',
              value: '${_sensorData['humidity'].toStringAsFixed(1)} %',
              color: Colors.green,
            ),
            _buildSensorCard(
              icon: Icons.cloud,
              title: 'Niveau de Gaz',
              value: '${_sensorData['gas'].toStringAsFixed(1)} ppm',
              color: Colors.orange,
            ),
            _buildSensorCard(
              icon: Icons.vibration,
              title: 'Vibration',
              value: _sensorData['vibration'] ? 'DÉTECTÉE' : 'Aucune',
              color: _sensorData['vibration'] ? Colors.red : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16)),
                Text(value,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}