import 'package:flutter/material.dart';
import 'package:kunci_pintu_iot/network/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../helper/regex.dart';
import '../auth/halaman_login.dart';

class UpdateProfile extends StatefulWidget {
  // const UpdateProfile({super.key});
  const UpdateProfile({Key? key}) : super(key: key);

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomorHpController = TextEditingController();

  List<String> options = ['laki-laki', 'perempuan'];
  String selectedValue = 'perempuan';

  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

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
        selectedValue = user['gender'];
        _nomorHpController.text = user['phone'];
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      isLoading = true;
    });

    var respon = await NetworkAPI().postAPI('/update-profile', true, {
      'name': _namaController.text,
      'email': _emailController.text,
      'gender': selectedValue,
      'phone': _nomorHpController.text,
    });

    var dataRespon = json.decode(respon.body);

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
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('userData', json.encode(dataRespon['data']));
      if (context.mounted) {
        Navigator.pop(context, 'updated');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'profil berhasil diperbarui',
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
        ));
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'ada yang salah',
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C0089),
      appBar: AppBar(
        title: const Text('Update Profil'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Email tidak boleh kosong';
                              }
                              if (RegexHelper().validatedEmail(value) ==
                                  false) {
                                return 'format email tidak sesuai';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _namaController,
                            keyboardType: TextInputType.text,
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedValue,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedValue = newValue!;
                                    });
                                  },
                                  items: options.map((value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _nomorHpController,
                            keyboardType: TextInputType.number,
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
                              onPressed: isLoading == true
                                  ? null
                                  : () {
                                      if (_formKey.currentState != null &&
                                          _formKey.currentState!.validate()) {
                                        _updateProfile();
                                      }
                                    },
                              child: Text(
                                  isLoading == true ? "Loading ..." : "Update"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
