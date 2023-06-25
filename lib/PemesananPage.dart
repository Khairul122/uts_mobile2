import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uts_mobile2/PemesananBangku.dart';
import 'package:uts_mobile2/homepage.dart';

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
  String? selectedDate;
  String? selectedRoute;
  String? selectedClass;
  int selectedSeatCount = 0;
  int hargaTiket = 0;

  final List<String> routes = ['Jakarta - Surabaya', 'Surabaya - Jakarta'];
  final List<String> classes = ['Ekonomi', 'VIP'];

  void onDateSelected(String? date) {
    setState(() {
      selectedDate = date;
    });
  }

  void onRouteSelected(String? route) {
    setState(() {
      selectedRoute = route;
      updateHargaTiket();
    });
  }

  void onClassSelected(String? classType) {
    setState(() {
      selectedClass = classType;
      updateHargaTiket();
    });
  }

  void onSeatCountSelected(int count) {
    setState(() {
      selectedSeatCount = count;
      updateHargaTiket();
    });
  }

  void updateHargaTiket() {
    if (selectedRoute == 'Jakarta - Surabaya' && selectedClass == 'Ekonomi') {
      hargaTiket = 100000 * selectedSeatCount;
    } else if (selectedRoute == 'Surabaya - Jakarta' &&
        selectedClass == 'Ekonomi') {
      hargaTiket = 100000 * selectedSeatCount;
    } else if (selectedRoute == 'Jakarta - Surabaya' &&
        selectedClass == 'VIP') {
      hargaTiket = 250000 * selectedSeatCount;
    } else if (selectedRoute == 'Surabaya - Jakarta' &&
        selectedClass == 'VIP') {
      hargaTiket = 250000 * selectedSeatCount;
    } else {
      hargaTiket = 0;
    }
  }

  void pesanTiket() async {
    if (selectedDate == null ||
        selectedRoute == null ||
        selectedClass == null ||
        selectedSeatCount == 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text('Harap lengkapi semua field'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
      return;
    }

    final url = Uri.parse('http://192.168.1.11/TiketBus/adddata.php');

    try {
      final response = await http.post(
        url,
        body: {
          'tanggal_pergi': selectedDate!,
          'rute_perjalanan': selectedRoute!,
          'kelas': selectedClass!,
          'jumlah_penumpang': selectedSeatCount.toString(),
          'harga_tiket': hargaTiket.toString(),
        },
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Sukses'),
            content: Text('Data berhasil disimpan'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PemesananBangkuPage(maxSeatCount: selectedSeatCount),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      } else {
        throw Exception(
            'Terjadi kesalahan saat mengirim data: ${response.statusCode}');
      }
    } catch (error) {
      String errorMessage = 'Terjadi kesalahan';
      if (error is Exception) {
        errorMessage = error.toString();
      }
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pemesanan Tiket Bus'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tanggal: ${selectedDate ?? "-"}',
              style: TextStyle(fontSize: 16.0),
            ),
            ElevatedButton(
              onPressed: () {
                // Tampilkan date picker
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 30)),
                ).then((selectedDate) {
                  if (selectedDate != null) {
                    onDateSelected(selectedDate.toString());
                  }
                });
              },
              child: Text('Pilih Tanggal'),
            ),
            SizedBox(height: 16.0),
            Text(
              'Rute: ${selectedRoute ?? "-"}',
              style: TextStyle(fontSize: 16.0),
            ),
            DropdownButton<String>(
              value: selectedRoute,
              hint: Text('Pilih Rute'),
              items: routes.map((route) {
                return DropdownMenuItem<String>(
                  value: route,
                  child: Text(route),
                );
              }).toList(),
              onChanged: onRouteSelected,
            ),
            SizedBox(height: 16.0),
            Text(
              'Kelas: ${selectedClass ?? "-"}',
              style: TextStyle(fontSize: 16.0),
            ),
            DropdownButton<String>(
              value: selectedClass,
              hint: Text('Pilih Kelas'),
              items: classes.map((classType) {
                return DropdownMenuItem<String>(
                  value: classType,
                  child: Text(classType),
                );
              }).toList(),
              onChanged: onClassSelected,
            ),
            SizedBox(height: 16.0),
            Text(
              'Jumlah Penumpang: $selectedSeatCount',
              style: TextStyle(fontSize: 16.0),
            ),
            Slider(
              value: selectedSeatCount.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              label: selectedSeatCount.toString(),
              onChanged: (double value) {
                onSeatCountSelected(value.toInt());
              },
            ),
            SizedBox(height: 16.0),
            Text(
              'Harga Tiket: Rp $hargaTiket',
              style: TextStyle(fontSize: 16.0),
            ),
            ElevatedButton(
              onPressed: pesanTiket,
              child: Text('Pesan Tiket'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
