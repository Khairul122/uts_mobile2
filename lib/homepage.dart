import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uts_mobile2/PemesananPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<String?>(
        future: fetchUsername(),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          } else {
            return HomePage(username: snapshot.data);
          }
        },
      ),
    );
  }
}

Future<String?> fetchUsername() async {
  final url = Uri.parse(
      'https://tiketbus-e3201-default-rtdb.firebaseio.com/users.json');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body) as Map<String, dynamic>;

    // Ganti email pengguna dengan email yang login berhasil
    final loggedInUser = responseData.entries.firstWhere(
      (entry) =>
          entry.value['email'] ==
          'user@example.com', // Ganti dengan email pengguna yang login
      orElse: () => null as MapEntry<String, dynamic>,
    );

    if (loggedInUser != null) {
      final username = loggedInUser.value['username'] as String?;
      return username;
    } else {
      throw Exception('User not found');
    }
  } else {
    throw Exception('Failed to fetch username');
  }
}

class HomePage extends StatelessWidget {
  final String? username;

  const HomePage({Key? key, this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 5.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Selamat Datang $username',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          SizedBox(
            height: 50.0,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PemesananPage()),
              );
            },
            child: const Text(
              'Pesan Tiket',
              style: TextStyle(fontSize: 18.0),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
