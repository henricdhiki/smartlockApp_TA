import 'package:flutter/material.dart';
import 'package:kunci_pintu_iot/network/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../auth/halaman_login.dart';
import 'dashboard.dart';
import 'update_profile.dart';

class Profile extends StatefulWidget {
  // const Profile({super.key});
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  ImageProvider? _imageProvider;

  String name = '', email = '', gender = '', phone = '', role = '';

  @override
  void initState() {
    super.initState();
    _loadImage();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userData = localStorage.getString('userData');

    if (userData != null && userData.isNotEmpty) {
      var user = json.decode(userData);

      setState(() {
        name = user['name'];
        email = user['email'];
        gender = user['gender'];
        role = user['role'];
        phone = user['phone'];
      });
    }
  }

  Future<void> _logout() async {
    final response = await NetworkAPI().getAPI('/logout', true);
    var dataRespon = json.decode(response.body);

    if (dataRespon['status'] == 'success') {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      await localStorage.setBool('isLogin', false);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HalamanLogin()),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Logout Gagal',
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  Future<void> _loadImage() async {
    try {
      final response = await NetworkAPI().getAPI('/avatar', true);

      setState(() {
        _imageProvider = MemoryImage(response.bodyBytes);
      });
    } catch (e) {
      throw Exception("failed to load avatar image : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C0089),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              CircleAvatar(
                radius: 77,
                backgroundImage: _imageProvider,
                backgroundColor: Colors.black26,
              ),
              const SizedBox(height: 20),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                phone,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "$role | $gender",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: Text("Upload Avatar"),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UpdateProfile()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: Text("Update Profil"),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: Text("Ganti Password"),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: Text("Logout"),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Dashboard()),
                    );
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
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
