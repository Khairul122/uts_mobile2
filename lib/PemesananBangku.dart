import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uts_mobile2/DataDiriPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pemesanan Tiket Bus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PemesananPage(),
    );
  }
}

class PemesananPage extends StatefulWidget {
  @override
  _PemesananPageState createState() => _PemesananPageState();
}

class _PemesananPageState extends State<PemesananPage> {
  int selectedSeatCount = 0;

  void pesanTiket() async {
    // Simulasi mendapatkan jumlah penumpang dari halaman sebelumnya
    int jumlahPenumpang = 4;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PemesananBangkuPage(
          maxSeatCount: jumlahPenumpang,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pemesanan Tiket Bus'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Jumlah Penumpang: $selectedSeatCount',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: pesanTiket,
              child: Text('Pilih Bangku'),
            ),
          ],
        ),
      ),
    );
  }
}

class PemesananBangkuPage extends StatefulWidget {
  final int maxSeatCount;

  PemesananBangkuPage({required this.maxSeatCount});

  @override
  _PemesananBangkuPageState createState() => _PemesananBangkuPageState();
}

class _PemesananBangkuPageState extends State<PemesananBangkuPage> {
  List<String> seatStatus = [];

  @override
  void initState() {
    super.initState();
    fetchData(); // Panggil fungsi fetchData saat membangun halaman
  }

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.11/TiketBus/get_seats.php'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        seatStatus = List<String>.from(data.map((seat) => seat['status']));
      });
    } else {
      // Gagal mendapatkan data, lakukan penanganan kesalahan
    }
  }

  void _navigateToDataDiriPage() async {
    List<int> selectedSeats = [];
    for (int i = 0; i < seatStatus.length; i++) {
      if (seatStatus[i] == 'selected') {
        selectedSeats.add(i + 1);
      }
    }

    if (selectedSeats.isNotEmpty) {
      // Mengirim permintaan HTTP POST untuk menyimpan data diri
      final response = await http.post(
        Uri.parse('http://192.168.1.11/TiketBus/add_data_diri.php'),
        body: {
          'nama': 'Nama Anda',
          'alamat': 'Alamat Anda',
          'no_telepon': 'Nomor Telepon Anda',
        },
      );

      if (response.statusCode == 200) {
        // Memperbarui status bangku menjadi "Unavailable" di MySQL
        for (int seat in selectedSeats) {
          final updateResponse = await http.post(
            Uri.parse('http://192.168.1.11/TiketBus/update_status_bangku.php'),
            body: {
              'no_bangku': seat.toString(),
              'status': 'unavailable',
            },
          );

          if (updateResponse.statusCode == 200) {
            print('Status bangku berhasil diperbarui: Bangku $seat');
          } else {
            print('Gagal memperbarui status bangku: Bangku $seat');
          }
        }

        // Pindah ke halaman DataDiriPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DataDiriPage(selectedSeats: selectedSeats),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Gagal Menyimpan Data'),
            content: Text('Terjadi kesalahan saat menyimpan data diri.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Peringatan'),
          content: Text('Anda belum memilih bangku.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int selectedCount =
        seatStatus.where((status) => status == 'selected').length;
    int bookedCount =
        seatStatus.where((status) => status == 'unavailable').length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pemesanan Tiket Bus'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSeatStatusIcon(Colors.green, 'Tersedia'),
                SizedBox(width: 16.0),
                _buildSeatStatusIcon(Colors.yellow, 'Terpilih'),
                SizedBox(width: 16.0),
                _buildSeatStatusIcon(Colors.red, 'Telah Terpesan'),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              itemCount: seatStatus.length,
              itemBuilder: (context, index) {
                String status = seatStatus[index];
                String seatDescription = '';

                return GestureDetector(
                  onTap: () {
                    if (status == 'available') {
                      if (selectedCount < widget.maxSeatCount) {
                        setState(() {
                          seatStatus[index] = 'selected';
                          selectedCount++;
                        });
                      } else {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Batas Maksimal Terpilih'),
                            content: Text(
                              'Anda hanya dapat memilih ${widget.maxSeatCount} bangku',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    } else if (status == 'selected') {
                      setState(() {
                        seatStatus[index] = 'available';
                        selectedCount--;
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: status == 'unavailable'
                          ? Colors.red
                          : status == 'selected'
                              ? Colors.yellow
                              : Colors.green,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          (index + 1).toString(),
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Positioned(
                          top: 8.0,
                          right: 8.0,
                          child: _buildSeatStatusIcon(
                              _getSeatStatusColor(status), seatDescription),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToDataDiriPage,
        label: Text('Pesan Bangku'),
        icon: Icon(Icons.shopping_cart),
      ),
    );
  }

  Widget _buildSeatStatusIcon(Color color, String description) {
    return Row(
      children: [
        Container(
          width: 16.0,
          height: 16.0,
          color: color,
        ),
        SizedBox(width: 8.0),
        Text(description),
      ],
    );
  }

  Color _getSeatStatusColor(String status) {
    if (status == 'unavailable') {
      return Colors.red;
    } else if (status == 'selected') {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }
}
