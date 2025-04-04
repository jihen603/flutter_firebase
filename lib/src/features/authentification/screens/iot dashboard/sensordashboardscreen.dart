import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../../../../../services/aes_helper.dart';
import '../../../../../services/iot_data_firebase.dart';

class SensorPage extends StatefulWidget {
  final String deviceType;
  final String? customKey;

  const SensorPage({super.key, this.deviceType = 'Arduino', this.customKey});

  @override
  _SensorPageState createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  late final IotDataFirebase _iotService;
  late StreamSubscription _dataSub;
  final Map<String, dynamic> _sensorData = {
    'temperature': 0.0,
    'humidity': 0.0,
    'gas': 0.0,
    'vibration': false,
    'soil_moisture': 0.0,
  };
  String _errorMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _iotService = IotDataFirebase();
    _startListening();
    _runInitialTests();
  }

  void _runInitialTests() async {
    try {
      AESHelper.testCompatibility();
    } catch (e) {
      debugPrint('Erreur test compatibilité: $e');
    }

    final isConnected = await _iotService.testConnection();
    if (!isConnected) {
      setState(() {
        _errorMessage = 'Erreur de connexion à Firebase';
        _isLoading = false;
      });
    }
  }

  void _startListening() {
    _dataSub = _iotService
        .getRealTimeData(deviceType: widget.deviceType)
        .listen((data) {
      if (mounted) {
        setState(() {
          _errorMessage = '';
          _isLoading = false;
          _sensorData.addAll(data);
        });
      }
    }, onError: (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur de flux de données: ${e.toString()}';
          _isLoading = false;
        });
      }
    });
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
        title: Text('Données ${widget.deviceType}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = '';
              });
              _startListening();
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startListening,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sensorData.length,
      itemBuilder: (ctx, index) {
        final key = _sensorData.keys.elementAt(index);
        final value = _sensorData[key];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _getIconForSensor(key),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDisplayName(key),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatValue(value),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getValueColor(key, value), // Correction ici
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Méthodes helper corrigées
  Widget _getIconForSensor(String key) {
    switch (key) {
      case 'temperature':
        return const Icon(Icons.thermostat, size: 32, color: Colors.orange);
      case 'humidity':
        return const Icon(Icons.water_drop, size: 32, color: Colors.blue);
      case 'gas':
        return const Icon(Icons.cloud, size: 32, color: Colors.grey);
      case 'vibration':
        return const Icon(Icons.vibration, size: 32, color: Colors.red);
      case 'soil_moisture':
        return const Icon(Icons.grass, size: 32, color: Colors.brown);
      default:
        return const Icon(Icons.device_unknown, size: 32);
    }
  }

  String _getDisplayName(String key) {
    return {
      'temperature': 'Température',
      'humidity': 'Humidité',
      'gas': 'Niveau de gaz',
      'vibration': 'Vibration',
      'soil_moisture': 'Humidité du sol',
    }[key] ?? key;
  }

  String _formatValue(dynamic value) {
    if (value is bool) {
      return value ? 'ACTIVE' : 'INACTIVE';
    } else if (value is double) {
      return value.toStringAsFixed(2);
    }
    return value.toString();
  }

  // Méthode corrigée avec le paramètre key
  Color _getValueColor(String key, dynamic value) {
    if (value is bool) {
      return value ? Colors.green : Colors.red;
    } else if (value is double) {
      if (key == 'temperature' && value > 30) return Colors.red;
      if (key == 'humidity' && value > 70) return Colors.blue;
    }
    return Colors.black;
  }
}