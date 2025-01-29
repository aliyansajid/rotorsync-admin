import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttScreen extends StatefulWidget {
  const MqttScreen({Key? key}) : super(key: key);

  @override
  _MqttScreenState createState() => _MqttScreenState();
}

class _MqttScreenState extends State<MqttScreen> {
  final TextEditingController brokerController = TextEditingController(
      text: "f77d059f31f34ca794ea8fd470a01062.s1.eu.hivemq.cloud");
  final TextEditingController portController =
      TextEditingController(text: "8883");
  final TextEditingController usernameController =
      TextEditingController(text: "aliyan");
  final TextEditingController passwordController =
      TextEditingController(text: "Aliyan2003#");

  MqttServerClient? client;
  String connectionStatus = "Disconnected ❌";

  Future<void> connectMQTT() async {
    String broker = brokerController.text.trim();
    int port = int.tryParse(portController.text) ?? 8883;
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    // Remove invalid prefixes
    broker = broker.replaceAll(RegExp(r'^(https://|mqtt://)'), '');

    client = MqttServerClient(broker, '');
    client!.port = port;
    client!.secure = true; // Enable TLS
    client!.keepAlivePeriod = 30; // Keep alive
    client!.logging(on: true);

    // Set MQTT v3.1.1 (same as HiveMQ Cloud)
    client!.setProtocolV311();

    // Callbacks
    client!.onConnected = () {
      setState(() {
        connectionStatus = "Connected ✅";
      });
      print("✅ MQTT Connected!");
    };

    client!.onDisconnected = () {
      setState(() {
        connectionStatus = "Disconnected ❌";
      });
      print("❌ MQTT Disconnected!");
    };

    // Connection message with unique client ID
    final connMessage = MqttConnectMessage()
        .withClientIdentifier(
            'flutter_client_${DateTime.now().millisecondsSinceEpoch}')
        .authenticateAs(username, password)
        .keepAliveFor(30)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client!.connectionMessage = connMessage;

    try {
      print("🔌 Connecting to broker: $broker on port $port...");
      await client!.connect();
    } catch (e) {
      setState(() {
        connectionStatus = "Failed to connect ❌";
      });
      print("⚠️ Connection failed: $e");
      client!.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MQTT Configuration"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: brokerController,
              decoration: const InputDecoration(labelText: "Broker URL"),
            ),
            TextField(
              controller: portController,
              decoration: const InputDecoration(labelText: "Port"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: connectMQTT,
              child: const Text("Connect"),
            ),
            const SizedBox(height: 20),
            Text(
              "Status: $connectionStatus",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: connectionStatus.contains("Connected")
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
