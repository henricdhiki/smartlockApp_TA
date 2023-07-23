import 'package:flutter/material.dart';

class InvalidQR extends StatelessWidget {
  const InvalidQR({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C0089),
      appBar: AppBar(
        title: const Text('Pindai QR'),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.redAccent,
          ),
          child: Row(
            children: const [
              Icon(Icons.remove_circle_outline, color: Colors.white),
              SizedBox(width: 20),
              Text(
                "error : kode QR invalid",
                style: TextStyle(
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
