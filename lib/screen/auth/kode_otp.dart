import 'package:flutter/material.dart';
import 'package:kunci_pintu_iot/network/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../dashboard/dashboard.dart';

class KodeOtp extends StatefulWidget {
  const KodeOtp({super.key});

  @override
  State<KodeOtp> createState() => _KodeOtpState();
}

class _KodeOtpState extends State<KodeOtp> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  String kodeOtp = '';

  void _sendOtp() async {
    setState(() {
      _isLoading = true;
    });

    final snackBarMessenger = ScaffoldMessenger.of(context);

    SharedPreferences localStorage = await SharedPreferences.getInstance();

    var token = localStorage.getString('token');

    // pastikan token tidak null
    if (token == null) {
      if (context.mounted) {
        Navigator.pop(context);
      }

      return;
    }

    final respon = await NetworkAPI().postAPI(
      '/verify-email',
      true,
      {'otp': kodeOtp},
    );

    var bodyRespon = json.decode(respon.body);

    if (bodyRespon['status'] == 'success') {
      await localStorage.setBool('isLogin', true);
      await localStorage.setString(
        'userData',
        json.encode(bodyRespon['data']),
      );

      if (context.mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const Dashboard()));
      }
    } else if (bodyRespon['status'] == 'otp_not_match') {
      snackBarMessenger.showSnackBar(const SnackBar(
        content: Text(
          'kode otp tidak sesuai',
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 3),
      ));
    } else if (bodyRespon['status'] == 'otp_expired') {
      if (context.mounted) {
        Navigator.pop(context);
      }
      snackBarMessenger.showSnackBar(const SnackBar(
        content: Text(
          'kode otp sudah kadaluarsa',
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 3),
      ));
    } else {
      snackBarMessenger.showSnackBar(const SnackBar(
        content: Text(
          'terjadi kesalahan',
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 3),
      ));
    }

    setState(() {
      _isLoading = false;
    });
  }

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
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Kode OTP',
                            border: OutlineInputBorder(),
                          ),
                          validator: (otpValue) {
                            if (otpValue == null || otpValue.isEmpty) {
                              return 'kode otp harus diisi';
                            }
                            if (otpValue.length != 6) {
                              return 'jumlah digit tidak sesuai';
                            }
                            kodeOtp = otpValue;
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        SizedBox(
                          height: 35,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState != null &&
                                        _formKey.currentState!.validate()) {
                                      _sendOtp();
                                    }
                                  },
                            child: Text(_isLoading ? 'Loading ...' : 'Kirim'),
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
