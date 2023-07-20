// import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';

// class BluetoothScann extends StatefulWidget {
//   const BluetoothScann({super.key});

//   @override
//   State<BluetoothScann> createState() => _BluetoothScannState();
// }

// class _BluetoothScannState extends State<BluetoothScann> {
//   FlutterBlue _flutterBlue = FlutterBlue.instance;
//   List<ScanResult> _devices = [];
//   bool _isScanning = false;

//   @override
//   void initState() {
//     super.initState();
//   }

//   Future<void> _startScan() async {
//     setState(() {
//       _isScanning = true;
//       _devices.clear();
//     });

//     _flutterBlue.scanResults.listen((results) {
//       setState(() {
//         _devices = results;
//       });
//     });

//     _flutterBlue.startScan();
//     await Future.delayed(Duration(seconds: 10)); // Scan for 10 seconds
//     _stopScan();
//   }

//   void _stopScan() {
//     _flutterBlue.stopScan();
//     setState(() {
//       _isScanning = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bluetooth Scan'),
//       ),
//       body: Column(
//         children: [
//           ElevatedButton(
//             onPressed: _isScanning ? null : _startScan,
//             child: Text('Mulai Scan'),
//           ),
//           ElevatedButton(
//             onPressed: _isScanning ? _stopScan : null,
//             child: Text('Hentikan Scan'),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: _devices.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(_devices[index].device.name.isNotEmpty
//                       ? _devices[index].device.name
//                       : 'Unknown'),
//                   subtitle: Text(_devices[index].device.id.toString()),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
