import 'package:flutter/material.dart';
import 'package:kunci_pintu_iot/network/api.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../auth/halaman_login.dart';

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
  bool isLoading = true;

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
      final List<dynamic> jsonData =
          dataRespon['data']; // Access the "data" key
      List<HistoryAccessCard> historyAccessCard =
          jsonData.map((data) => HistoryAccessCard.fromJson(data)).toList();
      setState(() {
        _historyAccessCardList = historyAccessCard;
        isLoading = false;
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
          ],
        ),
      ),
    );
  }
}
