import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../bluetooth/scann.dart';
import 'daftar_kunci.dart';
import 'daftar_pintu.dart';
import 'riwayat_akses.dart';
import 'profile.dart';

class Dashboard extends StatefulWidget {
  // const Dashboard({super.key});
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    getUserRole();
  }

  Future<void> getUserRole() async {
    final localStorage = await SharedPreferences.getInstance();
    var userData = json.decode(localStorage.getString('userData') ?? '');

    setState(() {
      _userRole = userData['role'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C0089),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            const Text(
              'Smart Lock',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage('timnas.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage('timnas.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        image: AssetImage('timnas.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Explore Menu',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(
              height: 15,
            ),
            if (_userRole == 'operator')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFB6CAFF),
                ),
                child: InkWell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(
                        Icons.door_back_door_outlined,
                        size: 30,
                        color: Colors.black,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Daftar Pintu',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'List pintu yang tersedia dalam sistem',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DaftarPintu()),
                    );
                  },
                ),
              ),
            if (_userRole == 'operator')
              const SizedBox(
                height: 12,
              ),
            if (_userRole == 'pengguna')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFB6CAFF),
                ),
                child: InkWell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(
                        Icons.key,
                        size: 30,
                        color: Colors.black,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Daftar Kunci',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'List kunci pintu yang tersedia untuk anda',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DaftarKunci()),
                    );
                  },
                ),
              ),
            if (_userRole == 'pengguna')
              const SizedBox(
                height: 12,
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFB6CAFF),
              ),
              child: InkWell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(
                      Icons.history_outlined,
                      size: 30,
                      color: Colors.black,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Riwayat Akses',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Daftar riwayat akses anda pada setiap pintu',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RiwayatAkses()),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            if (_userRole == 'operator')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFB6CAFF),
                ),
                child: InkWell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(
                        Icons.settings,
                        size: 30,
                        color: Colors.black,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Utility',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Pengaturan Perangkat Kunci Pintu',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => const RiwayatAkses()),
                    // );
                  },
                ),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BluetoothScann()),
          );
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
                  onPressed: () {},
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
