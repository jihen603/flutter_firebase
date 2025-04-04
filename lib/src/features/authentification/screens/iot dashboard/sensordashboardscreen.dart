import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../services/iot_data_firebase.dart';

class SensorDataPage extends StatefulWidget {
  const SensorDataPage({Key? key}) : super(key: key);

  @override
  _SensorDataPageState createState() => _SensorDataPageState();
}

class _SensorDataPageState extends State<SensorDataPage> {
  late StreamSubscription _dataSub;
  late IotDataFirebase _iotService;

  final Map<String, dynamic> _sensorData = {
    'temperature': 0.0,
    'humidity': 0.0,
    'gas': 0.0,
    'soil_moisture': 0.0,
    'vibration': false,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _iotService = Provider.of<IotDataFirebase>(context, listen: false);
    _startListening();
  }

  void _startListening() {
    _dataSub = _iotService.realTimeDecryptedData.listen((data) {
      if (mounted) {
        setState(() {
          _sensorData.updateAll((key, _) => data[key] ?? _sensorData[key]);
        });
      }
    }, onError: (e) => print('Erreur Stream: $e'));
  }

  @override
  void dispose() {
    _dataSub.cancel();
    super.dispose();
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSensorTile(
          icon: Icons.thermostat,
          title: 'Température',
          value: '${_sensorData['temperature'].toStringAsFixed(1)} °C',
          color: Colors.blue,
        ),
        _buildSensorTile(
          icon: Icons.water_drop,
          title: 'Humidité Air',
          value: '${_sensorData['humidity'].toStringAsFixed(1)} %',
          color: Colors.green,
        ),
        _buildSensorTile(
          icon: Icons.cloud,
          title: 'Niveau de Gaz',
          value: '${_sensorData['gas']} ppm',
          color: Colors.orange,
        ),
        _buildSensorTile(
          icon: Icons.grass,
          title: 'Humidité Sol',
          value: '${_sensorData['soil_moisture']}',
          color: Colors.brown,
        ),
        _buildSensorTile(
          icon: Icons.vibration,
          title: 'Vibration',
          value: _sensorData['vibration'] ? 'DÉTECTÉE' : 'Aucune',
          color: _sensorData['vibration'] ? Colors.red : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildSensorTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
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
}