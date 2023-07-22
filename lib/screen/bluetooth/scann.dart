import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'door_command.dart';

// ignore: must_be_immutable
class BluetoothScann extends StatefulWidget {
  String function;

  // const BluetoothScann({super.key});
  BluetoothScann({Key? key, required this.function}) : super(key: key);

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
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null && scanData.code != '') {
        String url = scanData.code!;

        if (widget.function == 'door-unlock') {
          _proccessUnlock(url);
        } else if (widget.function == 'door-config') {}
      }
    });
  }

  void _proccessUnlock(String text) {
    List<String> parts = text.split('/');
    parts.removeWhere((part) => part.isEmpty);

    if (parts.length != 5 ||
        parts[0] != 'https:' ||
        parts[1] != 'smartdoorlock.my.id' ||
        parts[2] != 'door') {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'kode QR tidak valid',
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
      ));
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
        title: Text(widget.function == 'door-unlock'
            ? 'Pindai Akses Cepat'
            : 'Register Perangkat Kunci'),
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
              child: Text(widget.function == 'door-unlock'
                  ? 'pindai kode QR pada pintu'
                  : 'pindai kode QR pada dashboard operator'),
            ),
          )
        ],
      ),
    );
  }
}
