import 'package:flutter/material.dart';
import 'package:kunci_pintu_iot/network/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../auth/halaman_login.dart';
import '../event_bus.dart';
import '../event.dart';

class DoorCard {
  final String id;
  final String name;
  final String connection;
  final String status;

  DoorCard({
    required this.id,
    required this.name,
    required this.connection,
    required this.status,
  });

  factory DoorCard.fromJson(Map<String, dynamic> json) {
    String doorConnection = '';
    String doorStatus = '';

    if (json['socket_id'] == null) {
      doorConnection = "Offline";
      doorStatus = "Tidak Diketahui";
    } else {
      doorConnection = "Online";
      if (json['is_lock'] == 1) {
        doorStatus = "Terkunci";
      } else {
        doorStatus = "Tidak Terkunci";
      }
    }

    return DoorCard(
      id: json['id'],
      name: json['name'],
      connection: doorConnection,
      status: doorStatus,
    );
  }
}

class DaftarPintu extends StatefulWidget {
  // const DaftarPintu({super.key});
  const DaftarPintu({Key? key}) : super(key: key);

  @override
  State<DaftarPintu> createState() => _DaftarPintuState();
}

class _DaftarPintuState extends State<DaftarPintu> {
  List<DoorCard> _doorCardList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initListener();
    _fetchDoorData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initListener() {
    eventBus.on<DoorUpdate>().listen((event) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'update pintu berhasil',
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
      ));
      _fetchDoorData();
    });

    eventBus.on<DoorRemoved>().listen((event) {
      _fetchDoorData();
    });

    eventBus.on<DoorRemoved>().listen((event) {
      _fetchDoorData();
    });
  }

  Future<void> _sendRemoteCommand(String id, String locking) async {
    final response = await NetworkAPI().postAPI('/remote-access', true, {
      'door_id': id,
      'locking': locking,
    });

    var dataRespon = json.decode(response.body);

    if (dataRespon['status'] == 'success') {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'perintah berhasil terkirim',
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  Future<void> _fetchDoorData() async {
    final response = await NetworkAPI().getAPI('/get-door', true);
    var dataRespon = json.decode(response.body);

    if (dataRespon['message'] != null) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setBool('isLogin', false);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HalamanLogin()),
        );
      }
    }

    if (dataRespon['status'] == 'success') {
      final List<dynamic> jsonData = dataRespon['data'];
      List<DoorCard> doorCard =
          jsonData.map((data) => DoorCard.fromJson(data)).toList();

      setState(() {
        _doorCardList = doorCard;
        isLoading = false;
      });
    } else {
      throw Exception('gagal load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C0089),
      appBar: AppBar(
        title: const Text('Daftar Pintu'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading == true)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFB6CAFF),
                ),
                child: Row(
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Text("Mengambil Data ...")
                  ],
                ),
              ),
            if (isLoading == false)
              Expanded(
                child: ListView.builder(
                  itemCount: _doorCardList.length,
                  itemBuilder: (context, index) {
                    final myDoors = _doorCardList[index];
                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFFB6CAFF),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.door_back_door_outlined,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(
                                    width: 18,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        myDoors.name,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        myDoors.connection,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 12),
                                      ),
                                      Text(
                                        myDoors.status,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (myDoors.connection == "Online")
                                ElevatedButton(
                                  onPressed: () {
                                    if (myDoors.status == "Terkunci") {
                                      _sendRemoteCommand(myDoors.id, "open");
                                    } else {
                                      _sendRemoteCommand(myDoors.id, "lock");
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 86, 84, 137),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 10),
                                    child: Text(myDoors.status == "Terkunci"
                                        ? "Buka"
                                        : "Kunci"),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
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
