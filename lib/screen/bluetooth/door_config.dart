import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'dart:typed_data';
import 'dart:convert';

// ignore: must_be_immutable
class DoorConfig extends StatefulWidget {
  BluetoothDevice device;
  String ssid;
  String password;
  String doorId;
  String event;

  DoorConfig({
    Key? key,
    required this.event,
    required this.device,
    required this.ssid,
    required this.password,
    required this.doorId,
  }) : super(key: key);

  @override
  State<DoorConfig> createState() => _DoorConfigState();
}

class _DoorConfigState extends State<DoorConfig> with WidgetsBindingObserver {
  // final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;
  List<int> buffer = [];

  String status = 'Menghubungkan ...';
  bool isLoading = true;
  bool isSuccess = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _connectToDevice();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopConnection();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopConnection();
    }
  }

  void _stopConnection() {
    _connection!.finish();
  }

  void _connectToDevice() async {
    try {
      _connection = await BluetoothConnection.toAddress(widget.device.address);

      if (_connection!.isConnected) {
        setState(() {
          status = "Mengirim Data ...";
        });
        _receiveMessage();
        _sendCommand();
      }
    } catch (e) {
      throw ('error: $e');
    }
  }

  void _sendCommand() {
    if (_connection != null) {
      if (widget.event == 'wifi-update') {
        String payload =
            '{"event":"wifi-update","data":{"ssid":"${widget.ssid}","password":"${widget.password}"}}';
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
            status = "Menunggu respon ...";
          });
        });
      } else if (widget.event == 'register') {
        String payload =
            '{"event":"register","data":{"door_id":"${widget.doorId}"}}';
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
            status = "Menunggu respon ...";
          });
        });
      }
    }
  }

  void _receiveMessage() {
    if (_connection != null) {
      _connection!.input?.listen((data) {
        buffer.addAll(data);
        int separatorIndex = buffer.indexOf(10);

        // jika eol ditemukan
        if (separatorIndex != -1) {
          // Ambil pesan dari buffer dan konversi ke dalam bentuk string
          List<int> messageBytes = buffer.sublist(0, separatorIndex - 1);
          String response = String.fromCharCodes(messageBytes);

          _handleRespon(response);

          // Hapus pesan dari buffer (termasuk karakter khusus '\n')
          buffer.removeRange(0, separatorIndex + 1);

          // Ulangi proses jika masih ada data yang tersisa di buffer
          if (buffer.isNotEmpty) {
            buffer.clear();
          }

          _stopConnection();
        }
      });
    }
  }

  void _handleRespon(String message) {
    if (message.startsWith('{') && message.endsWith('}')) {
      var statusRespon = json.decode(message);

      if (statusRespon['status'] == 'success') {
        setState(() {
          isSuccess = true;
          isLoading = false;
          status = "konfigurasi berhasil";
        });
      } else if (statusRespon['status'] == 'failed') {
        setState(() {
          isSuccess = false;
          isLoading = false;
          status = "konfigurasi gagal";
        });
      } else if (statusRespon['status'] == 'wifi_not_connected') {
        setState(() {
          isSuccess = false;
          isLoading = false;
          status = "register gagal, wifi belum terhubung";
        });
      } else {
        setState(() {
          isSuccess = false;
          isLoading = false;
          status = "register gagal";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C0089),
      appBar: AppBar(
        title: const Text('Konfigurasi Perangkat'),
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
                      widget.device.name!,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.device.address,
                      style: const TextStyle(
                        fontSize: 12,
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
                      Text(status)
                    ],
                  ),
                ),
              if (isLoading == true) const SizedBox(height: 20),
              if (isLoading == false && isSuccess == true)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.lightGreen,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline),
                      const SizedBox(width: 20),
                      Text(status)
                    ],
                  ),
                ),
              if (isLoading == false && isSuccess == true)
                const SizedBox(height: 20),
              if (isLoading == false && isSuccess == false)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.redAccent,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.remove_circle_outlined,
                          color: Colors.white),
                      const SizedBox(width: 20),
                      Text(
                        status,
                        style: const TextStyle(
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
