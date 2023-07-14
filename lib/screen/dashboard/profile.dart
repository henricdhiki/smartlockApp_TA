import 'package:flutter/material.dart';
import 'dashboard.dart';

class Profile extends StatelessWidget {
  final String _profileImagePath = 'path/to/profile_image.jpg';
  const Profile({Key? key}) : super(key: key);

  void _selectNewProfilePhoto() {
    // Implementasi aksi yang diinginkan saat tombol kamera pada avatar profil ditekan
    // Misalnya, menampilkan dialog untuk memilih gambar baru
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C0089),
      body: Container(
        child: Column(
          children: [
            SizedBox(height: 24),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 77,
                    backgroundImage: AssetImage(_profileImagePath),
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: _selectNewProfilePhoto,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            const Text(
              'Henric Dhiki Wicaksono',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            const Text(
              'henricdhiki@gmail.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  TextFormField(
                    initialValue: 'Nama Pengguna',
                    decoration: const InputDecoration(
                      labelText: 'Nama Pengguna',
                      fillColor: const Color(0xFFB6CAFF),
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    initialValue: 'Jenis Kelamin',
                    decoration: const InputDecoration(
                      labelText: 'Nomor Akun',
                      fillColor: const Color(0xFFB6CAFF),
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    initialValue: 'henricdhiki@gmail.com',
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      fillColor: const Color(0xFFB6CAFF),
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    initialValue: '081866855877',
                    decoration: const InputDecoration(
                      labelText: 'Nomor HP',
                      fillColor: const Color(0xFFB6CAFF),
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    initialValue: 'Pengguna',
                    decoration: const InputDecoration(
                      labelText: 'Role Akun',
                      fillColor: const Color(0xFFB6CAFF),
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Aksi yang ingin dilakukan saat tombol Logout ditekan
                      // Misalnya, menghapus data sesi login dan kembali ke halaman login
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                    ),
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Scan QR Code button pressed');
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Dashboard(),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  width: 20,
                ),
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.white),
                  onPressed: () {
                    print('Tombol Profile ditekan');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
