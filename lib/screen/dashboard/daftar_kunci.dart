import 'package:flutter/material.dart';
import 'package:kunci_pintu_iot/network/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../auth/halaman_login.dart';

class AccessCard {
  final String name;
  final String time;
  final String limit;
  final String status;

  AccessCard({
    required this.name,
    required this.time,
    required this.limit,
    required this.status,
  });

  factory AccessCard.fromJson(Map<String, dynamic> json) {
    return AccessCard(
      name: json['door']['name'],
      time: json['time_begin'] + " sd " + json['time_end'],
      limit: json['date_begin'] == null
          ? "Tidak Terbatas"
          : json['date_begin'] + " sd " + json['date_end'],
      status: json['is_running'] == 1 ? "Aktif" : "Terblokir",
    );
  }
}

class DaftarKunci extends StatefulWidget {
  // const DaftarKunci({super.key});
  const DaftarKunci({Key? key}) : super(key: key);

  @override
  State<DaftarKunci> createState() => _DaftarKunciState();
}

class _DaftarKunciState extends State<DaftarKunci> {
  List<AccessCard> _accessCardList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccessData();
  }

  Future<void> _fetchAccessData() async {
    final response = await NetworkAPI().getAPI('/my-access', true);

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
      List<AccessCard> accessCard =
          jsonData.map((data) => AccessCard.fromJson(data)).toList();
      setState(() {
        _accessCardList = accessCard;
        isLoading = false;
      });
    } else {
      throw Exception('failed to load access data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C0089),
      appBar: AppBar(
        title: const Text('Daftar Kunci Anda'),
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
                  itemCount: _accessCardList.length,
                  itemBuilder: (context, index) {
                    final myAccessCard = _accessCardList[index];
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
                                Icons.key,
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
                                    myAccessCard.name,
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
                                    myAccessCard.time,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                  Text(
                                    myAccessCard.limit,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    myAccessCard.status,
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
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
