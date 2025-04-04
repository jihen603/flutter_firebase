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
  late StreamSubscription _dataSubscription;
  late IotDataFirebase _iotDataService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Récupération du service une seule fois
    _iotDataService = Provider.of<IotDataFirebase>(context, listen: false);
    _setupRealTimeListener();
  }

  @override
  void dispose() {
    _dataSubscription.cancel();
    super.dispose();
  }

  void _setupRealTimeListener() {
    _dataSubscription = _iotDataService.realTimeDecryptedData.listen((data) {
      if (mounted) {
        setState(() {
          _sensorData = SensorData(
            temperature: data['temperature'] ?? 0.0,
            humidity: data['humidity'] ?? 0.0,
            gas: data['gas'] ?? 0.0,
            vibration: data['vibration'] == 1.0,
          );
        });
      }
    });
  }

  SensorData _sensorData = SensorData.initial();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Données des Capteurs en Temps Réel'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSensorCard(
            icon: Icons.thermostat,
            title: 'Température',
            value: '${_sensorData.temperature.toStringAsFixed(1)} °C',
            color: Colors.blue,
          ),
          _buildSensorCard(
            icon: Icons.water_drop,
            title: 'Humidité',
            value: '${_sensorData.humidity.toStringAsFixed(1)} %',
            color: Colors.green,
          ),
          _buildSensorCard(
            icon: Icons.cloud,
            title: 'Niveau de Gaz',
            value: '${_sensorData.gas.toStringAsFixed(1)} ppm',
            color: Colors.orange,
          ),
          _buildSensorCard(
            icon: Icons.vibration,
            title: 'Vibration',
            value: _sensorData.vibration ? 'DÉTECTÉE' : 'Aucune',
            color: _sensorData.vibration ? Colors.red : Colors.grey,
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
            Column(
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
          ],
        ),
      ),
    );
  }
}

// Modèle de données pour une meilleure typage
class SensorData {
  final double temperature;
  final double humidity;
  final double gas;
  final bool vibration;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.gas,
    required this.vibration,
  });

  factory SensorData.initial() => SensorData(
    temperature: 0.0,
    humidity: 0.0,
    gas: 0.0,
    vibration: false,
  );
}