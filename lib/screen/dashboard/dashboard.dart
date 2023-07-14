import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

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
    final snackBarMessenger = ScaffoldMessenger.of(context);
    final localStorage = await SharedPreferences.getInstance();

    var userData = localStorage.getString('userData') ?? '';

    setState(() {
      _userRole = userData;
    });

    snackBarMessenger.showSnackBar(SnackBar(
      content: Text(
        'data: $userData',
        textAlign: TextAlign.center,
      ),
      duration: const Duration(seconds: 10),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: Text('Read'),
            ),
            if (_userRole == 'operator')
              ElevatedButton(
                onPressed: () {},
                child: Text('Delete'),
              ),
          ],
        ),
      ),
    );
  }
}
