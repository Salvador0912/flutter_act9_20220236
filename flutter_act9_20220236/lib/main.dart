import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth casero',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Bluetooth casero'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final FlutterBlue _flutterBlue;
  BluetoothState _bluetoothState = BluetoothState.unknown;
  List<ScanResult> _devicesList = [];

  @override
  void initState() {
    super.initState();
    _flutterBlue = FlutterBlue.instance;

    _flutterBlue.state.listen((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _scanForDevices();
  }

  void _scanForDevices() {
    _flutterBlue.startScan(timeout: Duration(seconds: 4));

    _flutterBlue.scanResults.listen((results) {
      setState(() {
        _devicesList = results;
      });
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    await device.connect();
    List<BluetoothService> services = await device.discoverServices();
  }

  void _disconnectFromDevice(BluetoothDevice device) {
    device.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_bluetoothState == BluetoothState.on)
              const Text(
                'Bluetooth está encendido',
                style: TextStyle(fontSize: 18),
              )
            else if (_bluetoothState == BluetoothState.off)
              const Text(
                'Bluetooth está apagado',
                style: TextStyle(fontSize: 18),
              )
            else
              const Text(
                'Inicializando...',
                style: TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _devicesList.length,
                itemBuilder: (context, index) {
                  final device = _devicesList[index].device;
                  return ListTile(
                    title: Text(device.name),
                    subtitle: Text(device.id.toString()),
                    trailing: device.state == BluetoothDeviceState.connected
                        ? ElevatedButton(
                            onPressed: () => _disconnectFromDevice(device),
                            child: Text('Desconectado'),
                          )
                        : ElevatedButton(
                            onPressed: () => _connectToDevice(device),
                            child: Text('Conectado'),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
