import 'package:flutter/material.dart';
import 'package:kunci_pintu_iot/network/api.dart';
import 'package:kunci_pintu_iot/helper/regex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'reset_password.dart';
import 'kode_otp.dart';

import '../dashboard/dashboard.dart';

// class halaman login
class HalamanLogin extends StatefulWidget {
  // const HalamanLogin({super.key});
  const HalamanLogin({Key? key}) : super(key: key);

  @override
  State<HalamanLogin> createState() => _HalamanLoginState();
}

// implementasi class halaman login
class _HalamanLoginState extends State<HalamanLogin> {
  // inisialisasi state holder untuk status loading dan lihat password
  bool _isLoading = false;
  bool _secureText = true;

  // inisialisasi kunci formulir
  final _formKey = GlobalKey<FormState>();

  // inisialisasi data email dan password
  String email = '', password = '';

  TextEditingController passwordController = TextEditingController();

  // fungsi untuk melihat dan menutup password
  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  // fungsi login
  void _login() async {
    // atur status sekarang loading
    setState(() {
      _isLoading = true;
    });

    // inisialisasi context snackbar
    final snackBarMessenger = ScaffoldMessenger.of(context);

    // request login via api
    final respon = await NetworkAPI().authLogin(email, password);

    // ambil respon
    var bodyRespon = json.decode(respon.body);

    // jika login sukses
    if (bodyRespon['status'] == 'success') {
      // simpan token dan data user ke shared_preferences
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      await localStorage.setBool('isLogin', true);
      await localStorage.setString('token', bodyRespon['token']);
      await localStorage.setString('userData', json.encode(bodyRespon['data']));

      // pindah ke halaman dashboard
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
      }

      // jika login gagal
    } else if (bodyRespon['status'] == 'failed') {
      // tampilkan notifikasi
      snackBarMessenger.showSnackBar(const SnackBar(
        content: Text(
          'email atau password salah',
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
      ));
      passwordController.clear();
      // jika server tidak bisa dijangkau
    } else if (bodyRespon['status'] == 'email_unverified') {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('token', bodyRespon['token']);
      localStorage.setString('userData', json.encode(bodyRespon['data']));

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KodeOtp(),
          ),
        );
      }
    } else {
      // tampilkna notifikasi
      snackBarMessenger.showSnackBar(const SnackBar(
        content: Text(
          'terjadi kesalahan atau gangguan',
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
      ));
    }

    // login selesai, atur loading selesai
    setState(() {
      _isLoading = false;
    });
  }

  // build tampilan login
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('background.png'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Smart',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Lock™',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              const Text('Sistem Kunci Pintu Gedung Berbasi IoT'),
              const SizedBox(
                height: 40,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: (emailValue) {
                            // jika email kosong tampilkan peringatan
                            if (emailValue == null || emailValue.isEmpty) {
                              return 'email harus diisi';
                            }
                            // jika format email tidak sesuai tampilkan peringatan
                            if (RegexHelper().validatedEmail(emailValue) ==
                                false) {
                              return 'format email tidak sesuai';
                            }
                            // simpan data email
                            email = emailValue;
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          obscureText: _secureText,
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: const OutlineInputBorder(),
                            // tombol lihat password
                            suffixIcon: IconButton(
                              onPressed: showHide,
                              icon: Icon(_secureText
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                            ),
                          ),
                          validator: (passwordValue) {
                            // jika password kosong, tampilkan peringatan
                            if (passwordValue == null ||
                                passwordValue.isEmpty) {
                              return 'password harus diisi';
                            }
                            // simpan data password
                            password = passwordValue;
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                // pindah ke halaman reset password
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ResetPassword(),
                                  ),
                                );
                              },
                              child: const Text('Lupa Password?'),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          height: 35,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    // lakukan login jika validasi ok
                                    if (_formKey.currentState != null &&
                                        _formKey.currentState!.validate()) {
                                      _login();
                                    }
                                  },
                            child: Text(_isLoading ? 'Loading ...' : 'Login'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
