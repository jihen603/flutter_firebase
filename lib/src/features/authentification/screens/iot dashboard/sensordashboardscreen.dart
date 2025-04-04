import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../services/aes_helper.dart';
import '../../../../../services/iot_data_firebase.dart';


class SensorDashboard extends StatefulWidget {
  const SensorDashboard({Key? key}) : super(key: key);

  @override
  _SensorDashboardState createState() => _SensorDashboardState();
}

class _SensorDashboardState extends State<SensorDashboard> {
  late StreamSubscription _dataSub;
  final Map<String, dynamic> _sensorData = {
    'temperature': 0.0,
    'humidity': 0.0,
    'gas': 0.0,
    'soil_moisture': 0.0,
    'vibration': false,
  };

  @override
  void initState() {
    super.initState();
    _startListening();
    AESHelper.testDecryption(); // Test au démarrage
  }

  void _startListening() {
    final iotService = Provider.of<IotDataFirebase>(context, listen: false);
    _dataSub = iotService.realTimeData.listen((data) {
      if (mounted) {
        setState(() => _sensorData.addAll(data));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Capteurs IoT'),
        centerTitle: true,
      ),
      body: _buildDashboard(),
    );
  }

  Widget _buildDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSensorCard(
            icon: Icons.thermostat,
            title: 'Température',
            value: '${_sensorData['temperature'].toStringAsFixed(1)} °C',
            color: _getTemperatureColor(_sensorData['temperature']),
          ),
          _buildSensorCard(
            icon: Icons.water_drop,
            title: 'Humidité Air',
            value: '${_sensorData['humidity'].toStringAsFixed(1)} %',
            color: _getHumidityColor(_sensorData['humidity']),
          ),
          _buildSensorCard(
            icon: Icons.cloud,
            title: 'Niveau de Gaz',
            value: '${_sensorData['gas']} ppm',
            color: Colors.orange,
          ),
          _buildSensorCard(
            icon: Icons.grass,
            title: 'Humidité Sol',
            value: '${_sensorData['soil_moisture']}',
            color: Colors.brown,
          ),
          _buildSensorCard(
            icon: Icons.vibration,
            title: 'Vibration',
            value: _sensorData['vibration'] ? 'DÉTECTÉE' : 'Aucune',
            color: _sensorData['vibration'] ? Colors.red : Colors.grey,
          ),
        ],
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
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16)),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTemperatureColor(double temp) {
    if (temp > 30) return Colors.red;
    if (temp > 25) return Colors.orange;
    return Colors.blue;
  }

  Color _getHumidityColor(double humidity) {
    if (humidity > 70) return Colors.blue;
    if (humidity < 30) return Colors.amber;
    return Colors.green;
  }
}