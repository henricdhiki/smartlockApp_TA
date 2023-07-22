// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:kunci_pintu_iot/network/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

import '../auth/halaman_login.dart';
import 'update_password.dart';
import 'update_profile.dart';

class Profile extends StatefulWidget {
  // const Profile({super.key});
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  ImageProvider? _imageProvider;
  File? _image;

  bool isLoading = false;

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

  void _goToUpdateScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UpdateProfile()),
    );

    if (result != null) {
      _loadUserData();
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

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
        _uploadImageToServer();
      }
    });
  }

  Future<void> _uploadImageToServer() async {
    if (_image == null) {
      // Tidak ada gambar yang dipilih
      return;
    }

    setState(() {
      isLoading = true;
    });

    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');

    var url = Uri.parse(
        'https://smartdoorlock.my.id/api/update-avatar'); // Ganti URL sesuai dengan backend Anda
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    // Tambahkan file gambar ke request
    var imageFile = await http.MultipartFile.fromPath('avatar', _image!.path);
    request.files.add(imageFile);

    // Kirim request ke server
    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);
      if (jsonData['status'] == 'success') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              'avatar berhasil diperbarui',
              textAlign: TextAlign.center,
            ),
            duration: Duration(seconds: 2),
          ));
          _loadImage();
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              'format gambar tidak sesuai',
              textAlign: TextAlign.center,
            ),
            duration: Duration(seconds: 2),
          ));
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'terjadi kesalahan',
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
        ));
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C0089),
      appBar: AppBar(
        title: const Text('Profil Anda'),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
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
                  onPressed: isLoading == true
                      ? null
                      : () {
                          _pickImage(ImageSource.gallery);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                        isLoading == true ? "Loading ..." : "Upload Avatar"),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _goToUpdateScreen();
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UpdatePassword(),
                      ),
                    );
                  },
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
            ],
          ),
        ),
      ),
    );
  }
}
