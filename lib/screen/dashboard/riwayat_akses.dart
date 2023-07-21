import 'package:flutter/material.dart';
import 'package:kunci_pintu_iot/network/api.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import '../auth/halaman_login.dart';
import 'dashboard.dart';
import 'profile.dart';
// import 'dashboard.dart';

class HistoryAccessCard {
  final String name;
  final String time;
  final String status;

  HistoryAccessCard({
    required this.name,
    required this.time,
    required this.status,
  });

  factory HistoryAccessCard.fromJson(Map<String, dynamic> json) {
    return HistoryAccessCard(
      name: json['door']['name'],
      time: json['created_at'],
      status: json['log'],
    );
  }
}

class RiwayatAkses extends StatefulWidget {
  // const RiwayatAkses({super.key});
  const RiwayatAkses({Key? key}) : super(key: key);

  @override
  State<RiwayatAkses> createState() => _RiwayatAksesState();
}

class _RiwayatAksesState extends State<RiwayatAkses> {
  List<HistoryAccessCard> _historyAccessCardList = [];
  @override
  void initState() {
    super.initState();
    _fetchHistoryAccessData();
  }

  String formatTimestamp(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp).toLocal();
    String formattedDate = DateFormat('dd-MM-yyyy HH:mm:ss').format(dateTime);
    return formattedDate;
  }

  Future<void> _fetchHistoryAccessData() async {
    final response = await NetworkAPI().getAPI('/my-history', true);

    var dataRespon = json.decode(response.body);

    // jika login sudah kadaluarsa
    if (dataRespon['message'] != null) {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HalamanLogin()),
        );
      }
      return;
    }

    if (dataRespon['status'] == 'success') {
      final List<dynamic> jsonData =
          dataRespon['data']; // Access the "data" key
      List<HistoryAccessCard> historyAccessCard =
          jsonData.map((data) => HistoryAccessCard.fromJson(data)).toList();

      setState(() {
        _historyAccessCardList = historyAccessCard;
      });
    } else if (dataRespon['status'] == 'un') {
      throw Exception('Failed to load access data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C0089),
      appBar: AppBar(
        title: const Text('Riwayat Akses Anda'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: _historyAccessCardList.length,
                  itemBuilder: (context, index) {
                    final myHistoryAccessCard = _historyAccessCardList[index];
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.history_outlined,
                                size: 30,
                                color: Colors.black,
                              ),
                              const SizedBox(
                                width: 18,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    myHistoryAccessCard.name,
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
                                    formatTimestamp(myHistoryAccessCard.time),
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    myHistoryAccessCard.status,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    );
                  }),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // print('Scan QR Code button pressed');
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.qr_code),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
        child: BottomAppBar(
          color: const Color(0xFF358BE7),
          shape: const CircularNotchedRectangle(),
          child: SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.white),
                  onPressed: () {
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => const Dashboard()),
                    // );
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Dashboard()),
                        (route) => false);
                  },
                ),
                const SizedBox(
                  width: 20,
                ),
                const SizedBox(
                  width: 20,
                ),
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.white),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Profile()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
