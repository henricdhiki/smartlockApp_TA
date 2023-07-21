import 'package:flutter/material.dart';
import 'door_command.dart';

class BluetoothScann extends StatefulWidget {
  // const BluetoothScann({super.key});
  const BluetoothScann({Key? key}) : super(key: key);

  @override
  State<BluetoothScann> createState() => _BluetoothScannState();
}

class _BluetoothScannState extends State<BluetoothScann> {
  final TextEditingController _idPintu = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Scan'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                keyboardType: TextInputType.text,
                controller: _idPintu,
                decoration: const InputDecoration(
                  labelText: 'Id Pintu',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DoorCommand(
                          name: "Lab Tenaga Listrik",
                          id: "74ee1bd0-8a61-40c1-821f-f095acbc9fad",
                        ),
                      ),
                    );
                  },
                  child: const Text("Periksa"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
