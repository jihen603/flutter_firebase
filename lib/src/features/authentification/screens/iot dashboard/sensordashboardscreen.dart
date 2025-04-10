import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../../constants/image_strings.dart';

class SensorDashboard extends StatefulWidget {
  const SensorDashboard({Key? key}) : super(key: key);

  @override
  State<SensorDashboard> createState() => _SensorDashboardState();
}

class _SensorDashboardState extends State<SensorDashboard> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final String xorKey = "mysecretkey";

  // Valeurs actuelles des capteurs
  Map<String, String> sensorValues = {
    'Temperature': '0',
    'Humidity': '0',
    'Gas': '0',
    'Soil Moisture': '0',
    'Vibration': '0',
  };

  // Historique pour les graphiques (10 dernières mesures)
  Map<String, List<double>> sensorHistory = {
    'Temperature': [],
    'Humidity': [],
    'Gas': [],
    'Soil Moisture': [],
    'Vibration': [],
  };

  @override
  void initState() {
    super.initState();
    _listenToFirebase();
    _setupFirebaseMessaging();
  }

  void _setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Traite les notifications reçues
      if (message.notification != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(message.notification?.title ?? 'Notification'),
            content: Text(message.notification?.body ?? 'No message content'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Gestion de la notification quand l'utilisateur ouvre l'application
    });
  }

  void _listenToFirebase() {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          sensorValues['Temperature'] = xorDecrypt(data['DHT']?['temperature'] ?? '', xorKey);
          sensorValues['Humidity'] = xorDecrypt(data['DHT']?['humidity'] ?? '', xorKey);
          sensorValues['Gas'] = xorDecrypt(data['MQ5']?['gas'] ?? '', xorKey);
          sensorValues['Soil Moisture'] = xorDecrypt(data['MH-Sensor']?['soil_moisture'] ?? '', xorKey);
          sensorValues['Vibration'] = xorDecrypt(data['SW420']?['vibration'] ?? '', xorKey);

          _updateHistory('Temperature', sensorValues['Temperature']!);
          _updateHistory('Humidity', sensorValues['Humidity']!);
          _updateHistory('Gas', sensorValues['Gas']!);
          _updateHistory('Soil Moisture', sensorValues['Soil Moisture']!);
          _updateHistory('Vibration', sensorValues['Vibration']!);

          _checkThresholds();
        });
      }
    });
  }

  void _checkThresholds() {
    double temperature = double.tryParse(sensorValues['Temperature'] ?? '') ?? 0;
    double humidity = double.tryParse(sensorValues['Humidity'] ?? '') ?? 0;
    double gas = double.tryParse(sensorValues['Gas'] ?? '') ?? 0;
    double soilMoisture = double.tryParse(sensorValues['Soil Moisture'] ?? '') ?? 0;
    double vibration = double.tryParse(sensorValues['Vibration'] ?? '') ?? 0;

    // Seuils pour chaque capteur
    if (temperature > 30.0) {
      _sendFirebaseNotification("Alerte Température", "Température élevée : $temperature°C");
    }
    if (humidity > 60.0) {
      _sendFirebaseNotification("Alerte Humidité", "Humidité élevée : $humidity%");
    }
    if (gas > 600.0) {  // Seuil ajusté à 600 pour le gaz
      _sendFirebaseNotification("Alerte Gaz", "Concentration de gaz élevée : $gas");
    }
    if (soilMoisture < 40.0) {
      _sendFirebaseNotification("Alerte Sol", "Humidité du sol faible : $soilMoisture%");
    }
    if (vibration > 50.0) {
      _sendFirebaseNotification("Alerte Vibration", "Vibration détectée : $vibration");
    }
  }

  void _sendFirebaseNotification(String title, String message) {
    // Envoyer la notification via Firebase Cloud Messaging
    FirebaseMessaging.instance.subscribeToTopic('alerts');
    FirebaseMessaging.instance
        .sendMessage(
      to: '/topics/alerts',
      data: {
        'title': title,
        'message': message,
      },
    )
        .then((_) {
      print("Notification envoyée!");
    });
  }

  void _updateHistory(String sensor, String valueStr) {
    double value = double.tryParse(valueStr) ?? 0;
    sensorHistory[sensor]!.add(value);
    if (sensorHistory[sensor]!.length > 10) {
      sensorHistory[sensor]!.removeAt(0);
    }
  }

  String xorDecrypt(String base64Data, String key) {
    try {
      final bytes = base64.decode(base64Data);
      final decoded = String.fromCharCodes(bytes);
      final decrypted = List.generate(decoded.length, (i) {
        return decoded.codeUnitAt(i) ^ key.codeUnitAt(i % key.length);
      });
      return String.fromCharCodes(decrypted);
    } catch (e) {
      return 'Error';
    }
  }

  Widget buildSensorCard(
      String sensorName, String sensorValue, IconData icon, List<double> history, Color color) {
    return Card(
      color: Colors.black26,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(width: 12),
                Text(
                  sensorName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Spacer(),
                Text(
                  sensorValue,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: SensorGraph(
                graphData: history,
                color: color,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan flou
          Positioned.fill(
            child: Image.asset(
              tSplashTopImage,  // Remplacer par le chemin de votre image
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),
          // Contenu principal
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Text(
                      "IoT Dashboard",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    buildSensorCard(
                      'Temperature',
                      sensorValues['Temperature'] ?? '',
                      Icons.thermostat,
                      sensorHistory['Temperature'] ?? [],
                      Colors.orange,
                    ),
                    buildSensorCard(
                      'Humidity',
                      sensorValues['Humidity'] ?? '',
                      Icons.water_drop,
                      sensorHistory['Humidity'] ?? [],
                      Colors.blue,
                    ),
                    buildSensorCard(
                      'Gas',
                      sensorValues['Gas'] ?? '',
                      Icons.cloud,
                      sensorHistory['Gas'] ?? [],
                      Colors.red,
                    ),
                    buildSensorCard(
                      'Soil Moisture',
                      sensorValues['Soil Moisture'] ?? '',
                      Icons.terrain,
                      sensorHistory['Soil Moisture'] ?? [],
                      Colors.green,
                    ),
                    buildSensorCard(
                      'Vibration',
                      sensorValues['Vibration'] ?? '',
                      Icons.vibration,
                      sensorHistory['Vibration'] ?? [],
                      Colors.purple,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SensorGraph extends StatelessWidget {
  final List<double> graphData;
  final Color color;

  const SensorGraph({
    required this.graphData,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(
      graphData.length,
          (index) => FlSpot(index.toDouble(), graphData[index]),
    );

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey, strokeWidth: 0.5),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(0),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),            ),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  'Day ${(value + 1).toInt()}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.black, width: 1),
        ),
        backgroundColor: Colors.transparent,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

