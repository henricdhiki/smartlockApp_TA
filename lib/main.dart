import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screen/notification.dart';

import 'screen/event_bus.dart';
import 'screen/event.dart';

import 'screen/auth/halaman_login.dart';
import 'screen/dashboard/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  eventBus.on<DoorAlert>().listen((event) {
    NotificationService().showNotification(
      title: 'Peringatan Pintu',
      body: event.message,
    );
  });

  runApp(const MyApp());
}

// class applikasi
class MyApp extends StatelessWidget {
  // const MyApp({super.key});
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      // aplikasi pertama kali akan memeriksa login user
      home: CheckAuth(),
    );
  }
}

// class cek login
class CheckAuth extends StatefulWidget {
  const CheckAuth({Key? key}) : super(key: key);

  @override
  State<CheckAuth> createState() => _CheckAuthState();
}

// implementasi class cek login
class _CheckAuthState extends State<CheckAuth> {
  bool isLoggedIn = false;

  // lakukan pengecekan login pada fungsi init
  @override
  void initState() {
    super.initState();
    _checkIsLoggedIn();
  }

  // fungsi cek login
  void _checkIsLoggedIn() async {
    // ambil token user
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var loggedIn = localStorage.getBool('isLogin');

    // jika token ada
    if (loggedIn != null && loggedIn == true) {
      // atur status sudah login
      if (mounted) {
        setState(() {
          isLoggedIn = true;
        });
      }
    }
  }

  // build tampilan layar
  @override
  Widget build(BuildContext context) {
    Widget child;

    // jika sudah login tampilkan dashboard
    if (isLoggedIn) {
      child = const Dashboard();
    }
    // jika belum login tampilkan halaman login
    else {
      child = const HalamanLogin();
    }

    // tampilkan layar
    return Scaffold(
      body: child,
    );
  }
}
