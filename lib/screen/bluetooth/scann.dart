import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'door_command.dart';
import 'door_config.dart';
import 'invalid_qr.dart';

// ignore: must_be_immutable
class BluetoothScann extends StatefulWidget {
  String function;
  BluetoothDevice? device;

  // const BluetoothScann({super.key});
  BluetoothScann({Key? key, required this.function, required this.device})
      : super(key: key);

  @override
  State<BluetoothScann> createState() => _BluetoothScannState();
}

class _BluetoothScannState extends State<BluetoothScann> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  String url = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller!.stopCamera();
    controller!.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        String url = scanData.code!;
        controller.stopCamera();
        _proccessUnlock(url);
      }
    });
  }

  void _proccessUnlock(String text) {
    if (widget.function == 'door-config') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DoorConfig(
            event: 'register',
            device: widget.device!,
            ssid: 'text',
            password: 'text',
            doorId: text,
          ),
        ),
      );
    } else if (widget.function == 'quick-scann') {
      List<String> parts = text.split('/');
      parts.removeWhere((part) => part.isEmpty);

      if (parts.length != 5 ||
          parts[0] != 'https:' ||
          parts[1] != 'smartdoorlock.my.id' ||
          parts[2] != 'door') {
        controller?.dispose();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const InvalidQR(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DoorCommand(
              id: parts[3],
              name: hexToAscii(parts[4]),
            ),
          ),
        );
      }
    }
  }

  String hexToAscii(String hexString) {
    List<String> bytePairs = [];
    for (int i = 0; i < hexString.length; i += 2) {
      bytePairs.add(hexString.substring(i, i + 2));
    }

    List<int> bytes =
        bytePairs.map((byte) => int.parse(byte, radix: 16)).toList();

    String asciiString = String.fromCharCodes(bytes);
    return asciiString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pindai Akses Cepat'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(widget.function == 'quick-scann'
                  ? 'pindai kode QR pada pintu'
                  : 'pindai kode QR pada dashboard operator'),
            ),
          )
        ],
      ),
    );
  }
}
