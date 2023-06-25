import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uts_mobile2/TiketPage.dart';

class DataDiriPage extends StatefulWidget {
  final List<int> selectedSeats;

  DataDiriPage({required this.selectedSeats});

  @override
  _DataDiriPageState createState() => _DataDiriPageState();
}

class _DataDiriPageState extends State<DataDiriPage> {
  TextEditingController _namaController = TextEditingController();
  TextEditingController _alamatController = TextEditingController();
  TextEditingController _noTeleponController = TextEditingController();

  Future<void> _simpanDataDiri() async {
    String url = 'http://192.168.1.11/TiketBus/add_data_diri.php';

    String nama = _namaController.text;
    String alamat = _alamatController.text;
    String noTelepon = _noTeleponController.text;

    // Validasi nomor telepon
    if (!noTelepon.startsWith('08')) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Nomor telepon harus dimulai dengan "08".'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    var response = await http.post(
      Uri.parse(url),
      body: {
        'nama': nama,
        'alamat': alamat,
        'no_telepon': noTelepon,
      },
    );

    if (response.statusCode == 200) {
      // Berhasil menyimpan data
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Sukses'),
            content: Text('Data diri berhasil disimpan.'),
            actions: [
              TextButton(
                onPressed: () {
                  // Mengubah status bangku menjadi "Unavailable" di MySQL
                  for (int seat in widget.selectedSeats) {
                    _updateStatusBangku(seat);
                  }
                  Navigator.of(context).pop();

                  // Tampilkan halaman TiketPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TiketPage(
                        nama: nama,
                        alamat: alamat,
                        noTelepon: noTelepon,
                        nomorBangku: widget.selectedSeats,
                      ),
                    ),
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Gagal menyimpan data
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Terjadi kesalahan saat menyimpan data.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _updateStatusBangku(int seatNumber) async {
    String updateUrl = 'http://192.168.1.11/TiketBus/update_status_bangku.php';
    var updateResponse = await http.post(
      Uri.parse(updateUrl),
      body: {
        'nomor_bangku': seatNumber.toString(),
        'status': 'Unavailable',
      },
    );
    if (updateResponse.statusCode == 200) {
      print('Status bangku $seatNumber berhasil diubah.');
    } else {
      print('Terjadi kesalahan saat mengubah status bangku $seatNumber.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Diri Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 20.0),
              Text(
                'Isi Data Diri',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _alamatController,
                decoration: InputDecoration(
                  labelText: 'Alamat',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _noTeleponController,
                decoration: InputDecoration(
                  labelText: 'No Telepon',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              SizedBox(height: 30.0),
              if (widget.selectedSeats.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bangku Terpilih:',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Nomor Bangku: ${widget.selectedSeats.join(', ')}',
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _simpanDataDiri,
                child: Text(
                  'Simpan',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 60.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PemesananBangkuPage extends StatefulWidget {
  final int maxSeatCount;
  final List<int> selectedSeats;

  PemesananBangkuPage(
      {required this.maxSeatCount, required this.selectedSeats});

  @override
  _PemesananBangkuPageState createState() => _PemesananBangkuPageState();
}

class _PemesananBangkuPageState extends State<PemesananBangkuPage> {
  void _navigateToDataDiriPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DataDiriPage(selectedSeats: widget.selectedSeats),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pemesanan Tiket Bus'),
      ),
      body: Column(
        children: [
          Text(
            'Max Seat: ${widget.maxSeatCount}',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.0),
          if (widget.selectedSeats.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daftar Bangku Dipilih:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.selectedSeats.length,
                    itemBuilder: (context, index) {
                      int selectedSeat = widget.selectedSeats[index];
                      return Text('Bangku ${selectedSeat.toString()}');
                    },
                  ),
                ],
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
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Diri App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PemesananBangkuPage(
        maxSeatCount: 10,
        selectedSeats: [],
      ),
    );
  }
}
