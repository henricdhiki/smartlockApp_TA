import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'door_config.dart';
import 'scann.dart';

class BluetoothUtil extends StatefulWidget {
  const BluetoothUtil({Key? key}) : super(key: key);

  @override
  State<BluetoothUtil> createState() => _BluetoothUtilState();
}

class _BluetoothUtilState extends State<BluetoothUtil> {
  List<BluetoothDevice> _boundedDevices = [];
  BluetoothDevice? _selectedDevice;

  final _formKey = GlobalKey<FormState>();

  TextEditingController ssidController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getBoundedDevices();
  }

  void _getBoundedDevices() async {
    try {
      List<BluetoothDevice> boundedDevices =
          await FlutterBluetoothSerial.instance.getBondedDevices();

      setState(() {
        _boundedDevices = boundedDevices
            .where((device) => device.name!.startsWith("DOOR:"))
            .toList();
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'kesalahan: $e',
              textAlign: TextAlign.center,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C0089),
      appBar: AppBar(
        title: const Text('Pengaturan IoT'),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Perangkat Kunci IoT *',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey),
                  color: Colors.white,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<BluetoothDevice>(
                      value: _selectedDevice,
                      items: _boundedDevices.map((device) {
                        return DropdownMenuItem<BluetoothDevice>(
                          value: device,
                          child: Text(device.name ?? 'Tidak Diketahui'),
                        );
                      }).toList(),
                      onChanged: (BluetoothDevice? device) {
                        setState(() {
                          _selectedDevice = device;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                'Pengaturan WiFi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: ssidController,
                          decoration: const InputDecoration(
                            labelText: 'SSID',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            // jika email kosong tampilkan peringatan
                            if (value == null || value.isEmpty) {
                              return 'SSID harus diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            // jika email kosong tampilkan peringatan
                            if (value == null || value.isEmpty) {
                              return 'Password harus diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 40,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState != null &&
                                  _formKey.currentState!.validate()) {
                                if (_selectedDevice == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'error: perangkat kunci kosong',
                                        textAlign: TextAlign.center,
                                      ),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DoorConfig(
                                        event: 'wifi-update',
                                        device: _selectedDevice!,
                                        ssid: ssidController.text,
                                        password: passwordController.text,
                                        doorId: 'text',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('Kirim'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                'Register Ke Server',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 40,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (_selectedDevice != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BluetoothScann(
                            function: 'door-config',
                            device: _selectedDevice,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Pindai QR Pendaftaran'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
