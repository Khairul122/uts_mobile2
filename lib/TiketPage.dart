import 'package:flutter/material.dart';

class TiketPage extends StatelessWidget {
  final String nama;
  final String alamat;
  final String noTelepon;
  final List<int> nomorBangku;

  TiketPage({
    required this.nama,
    required this.alamat,
    required this.noTelepon,
    required this.nomorBangku,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E-Tiket'),
        backgroundColor:
            Colors.blue, // Ubah warna latar belakang AppBar menjadi biru
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Card(
            margin: EdgeInsets.all(16.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'E-Tiket Sementara',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nama: $nama',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Alamat: $alamat',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No. Telepon: $noTelepon',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nomor Bangku:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: nomorBangku.map((bangku) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Bangku $bangku',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Harap tunggu konfirmasi admin untuk tiket aslinya.',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
