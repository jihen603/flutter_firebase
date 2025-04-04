import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import '../../../../../services/encryption_service.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/image_strings.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String temperature = "Loading...";
  String light = "Loading...";
  List<FlSpot> temperatureData = [];
  List<FlSpot> lightData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final databaseRef = FirebaseDatabase.instance.ref();

    databaseRef.child("sensors").onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map?;
      if (data != null && data["encrypted_data"] != null) {
        String encryptedData = data["encrypted_data"];
        String decryptedData = EncryptionService.decryptData(encryptedData);

        Map<String, dynamic> jsonData = json.decode(decryptedData);
        double tempValue = double.tryParse(jsonData["temperature"].toString()) ?? 0;
        double lightValue = double.tryParse(jsonData["light"].toString()) ?? 0;

        setState(() {
          temperature = "${tempValue.toStringAsFixed(1)}°C";
          light = "${lightValue.toStringAsFixed(1)} lx";

          if (temperatureData.length > 50) temperatureData.removeAt(0);
          if (lightData.length > 50) lightData.removeAt(0);

          temperatureData.add(FlSpot(temperatureData.length.toDouble(), tempValue));
          lightData.add(FlSpot(lightData.length.toDouble(), lightValue));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contiki Cooja Sensor Dashboard")),  // Nouveau titre
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              tSplashTopImage,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SensorCard(title: "Simulated Temperature (°C)", value: temperature, icon: Icons.thermostat, color: orangeColor),
                    SensorCard(title: "Simulated Light Intensity (lx)", value: light, icon: Icons.lightbulb, color: yellowColor),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(child: SensorGraph(title: "Simulated Temperature Evolution", graphData: temperatureData, color: orangeColor)),
                SizedBox(height: 20),
                Expanded(child: SensorGraph(title: "Simulated Light Intensity Evolution", graphData: lightData, color: yellowColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SensorCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black.withOpacity(0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 5),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class SensorGraph extends StatelessWidget {
  final String title;
  final List<FlSpot> graphData;
  final Color color;

  const SensorGraph({required this.title, required this.graphData, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        SizedBox(height: 10),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true, getDrawingHorizontalLine: (value) {
                return FlLine(color: Colors.grey, strokeWidth: 0.5);
              }),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                  return Text('Day ${(value + 1).toInt()}');  // Afficher les jours sous l'axe X
                })),
              ),
              borderData: FlBorderData(show: true, border: Border.all(color: Colors.black, width: 1)),
              lineBarsData: [
                LineChartBarData(
                  spots: graphData,
                  isCurved: true,
                  color: color,
                  barWidth: 3,
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
