import 'package:flutter/material.dart';
import 'package:kunci_pintu_iot/helper/regex.dart';
import 'package:kunci_pintu_iot/network/api.dart';
import 'dart:convert';

// class reset password
class ResetPassword extends StatefulWidget {
  // const ResetPassword({super.key});
  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

// implementasi class reset password
class _ResetPasswordState extends State<ResetPassword> {
  bool _isLoading = false;
  String email = '';

  final _formKey = GlobalKey<FormState>();

  void _sendLink() async {
    setState(() {
      _isLoading = true;
    });

    final snackBarMessenger = ScaffoldMessenger.of(context);
    final response =
        await NetworkAPI().postAPI('/reset-password', false, {'email': email});

    var bodyRespon = json.decode(response.body);

    if (bodyRespon['status'] == 'success') {
      if (context.mounted) {
        Navigator.pop(context);
      }
      snackBarMessenger.showSnackBar(SnackBar(
        content: Text(
          'link berhasil terkirim ke $email',
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 2),
      ));
    } else if (bodyRespon['status'] == 'failed') {
      snackBarMessenger.showSnackBar(const SnackBar(
        content: Text(
          'gagal, email tidak ditemukan',
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
      ));
    } else {
      snackBarMessenger.showSnackBar(const SnackBar(
        content: Text(
          'terjadi kesalahan atau gangguan',
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
      ));
    }

    setState(() {
      _isLoading = false;
    });
  }

  // build tampilan layar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
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
                            if (emailValue == null || emailValue.isEmpty) {
                              return 'email harus diisi';
                            }
                            if (RegexHelper().validatedEmail(emailValue) ==
                                false) {
                              return 'format email tidak sesuai';
                            }
                            email = emailValue;
                            return null;
                          },
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
                                    if (_formKey.currentState != null &&
                                        _formKey.currentState!.validate()) {
                                      _sendLink();
                                    }
                                  },
                            child:
                                Text(_isLoading ? 'Loading ...' : 'Kirim Link'),
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
