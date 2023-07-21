import 'package:flutter/material.dart';
import 'package:kunci_pintu_iot/network/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'dashboard.dart';
import 'profile.dart';

class UpdateProfile extends StatefulWidget {
  // const UpdateProfile({super.key});
  const UpdateProfile({Key? key}) : super(key: key);

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  TextEditingController _namaController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _nomorHpController = TextEditingController();
  TextEditingController _jenisKelaminController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userData = localStorage.getString('userData');

    if (userData != null && userData.isNotEmpty) {
      var user = json.decode(userData);

      setState(() {
        _namaController.text = user['name'];
        _emailController.text = user['email'];
        _jenisKelaminController.text = user['gender'];
        _nomorHpController.text = user['phone'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C0089),
      appBar: AppBar(
        title: const Text('Update Profil'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _namaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _jenisKelaminController,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Kelamin',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Jenis Kelamin tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _nomorHpController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor HP',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Nomor HP tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 35,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          // onPressed: _isLoading
                          //     ? null
                          //     : () {
                          //         // lakukan login jika validasi ok
                          //         if (_formKey.currentState != null &&
                          //             _formKey.currentState!.validate()) {
                          //           _login();
                          //         }
                          //       },
                          child: const Text("Update"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
