import 'package:flutter/material.dart';
import 'package:kunci_pintu_iot/network/api.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:typed_data';
import 'dart:convert';

class DoorCommand extends StatefulWidget {
  final String name;
  final String id;

  const DoorCommand({Key? key, required this.name, required this.id})
      : super(key: key);

  @override
  State<DoorCommand> createState() => _DoorCommandState();
}

class _DoorCommandState extends State<DoorCommand> with WidgetsBindingObserver {
  String accessStatus = "Meminta Akses ...";
  String loadingMessage = "Memeriksa akses ...";
  bool isLoading = true;
  bool isSuccess = false;
  bool isSearching = true;

  String bluetoothName = '';
  String doorKey = '';
  String userId = '';

  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestAccess();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopScan();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopScan();
    }
  }

  void _stopScan() {
    _bluetooth.cancelDiscovery();
  }

  void _requestAccess() async {
    final response =
        await NetworkAPI().getAPI('/verify-access/${widget.id}', true);
    var dataRespon = json.decode(response.body);

    if (dataRespon['status'] == 'no_data') {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'ada yang salah',
              textAlign: TextAlign.center,
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
      await Future.delayed(const Duration(seconds: 3));
      if (context.mounted) {
        Navigator.pop(context);
      }
      return;
    }

    if (dataRespon['status'] == 'success') {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      var userData = localStorage.getString('userData');
      var user = json.decode(userData!);

      bluetoothName = "DOOR:${dataRespon['data']['bluetooth']}";
      doorKey = dataRespon['data']['key'];
      userId = user['id'];

      setState(() {
        accessStatus = "Akses Diijinkan";
        loadingMessage = "Menghubungkan ...";
      });

      _searchDevice();
    } else {
      setState(() {
        accessStatus = "Akses Ditolak";
        isLoading = false;
      });
    }
  }

  void _searchDevice() async {
    try {
      _bluetooth.startDiscovery().listen((result) {
        if (result.device.name == bluetoothName) {
          setState(() {
            isSearching = false;
          });
          _stopScan();
          _connectToDevice(result.device);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'terjadi kesalahan: $e',
            textAlign: TextAlign.center,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(seconds: 3));
      if (context.mounted) {
        Navigator.pop(context);
      }
    }

    await Future.delayed(const Duration(seconds: 10));

    if (isSearching == true) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _connectToDevice(BluetoothDevice device) async {
    BluetoothConnection connection =
        await BluetoothConnection.toAddress(device.address);
    if (connection.isConnected) {
      setState(() {
        _connection = connection;
      });
      _sendCommand();
      _receiveMessage();
    } else {}
  }

  void _sendCommand() {
    if (_connection != null) {
      String payload =
          '{"event":"door-unlock","data":{"door_id":"${widget.id}","user_id":"$userId","key":"$doorKey"}}';
      _connection!.output.add(Uint8List.fromList(payload.codeUnits));
      _connection!.output.allSent.then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'perintah terkirim',
              textAlign: TextAlign.center,
            ),
            duration: Duration(seconds: 2),
          ),
        );

        setState(() {
          loadingMessage = "Menunggu respon ...";
        });
      });
    }
  }

  void _receiveMessage() {
    if (_connection != null) {
      _connection!.input?.listen((Uint8List data) {
        String response = String.fromCharCodes(data);
        var statusRespon = json.decode(response);

        if (statusRespon['status'] == 'success' ||
            statusRespon['status'] == 'door_aleady_open') {
          setState(() {
            isSuccess = true;
            isLoading = false;
          });
          _connection!.finish();
        } else {
          _connection!.finish();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C0089),
      appBar: AppBar(
        title: const Text('Akses Cepat'),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFB6CAFF),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.id,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      accessStatus,
                      style: TextStyle(
                        color: accessStatus == "Akses Ditolak"
                            ? Colors.red
                            : Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (isLoading == true)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFB6CAFF),
                  ),
                  child: Row(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(width: 20),
                      Text(loadingMessage)
                    ],
                  ),
                ),
              if (isLoading == true) const SizedBox(height: 20),
              if (accessStatus == 'Akses Diijinkan' &&
                  isLoading == false &&
                  isSuccess == true)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.lightGreen,
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: 20),
                      Text("Pintu sudah terbuka")
                    ],
                  ),
                ),
              if (accessStatus == 'Akses Diijinkan' &&
                  isLoading == false &&
                  isSuccess == true)
                const SizedBox(height: 20),
              if (accessStatus == 'Akses Diijinkan' &&
                  isLoading == false &&
                  isSuccess == false)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.redAccent,
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.remove_circle_outlined, color: Colors.white),
                      SizedBox(width: 20),
                      Text(
                        "timeout : pintu tidak merespon",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
