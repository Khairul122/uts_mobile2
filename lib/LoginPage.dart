import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uts_mobile2/RegistrasiPage.dart';
import 'package:uts_mobile2/homepage.dart';

void main() => runApp(LoginPage());

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traveloka Login',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPageScreen(),
    );
  }
}

class LoginPageScreen extends StatefulWidget {
  @override
  _LoginPageScreenState createState() => _LoginPageScreenState();
}

class _LoginPageScreenState extends State<LoginPageScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silahkan isi email dan password anda'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final url = Uri.parse(
        'https://tiketbus-e3201-default-rtdb.firebaseio.com/users.json');

    try {
      final response = await http.get(url);
      final responseData = json.decode(response.body);

      if (responseData != null) {
        bool isLoginSuccessful = false;
        String? username;

        responseData.forEach((key, value) {
          if (value['email'] == email && value['password'] == password) {
            isLoginSuccessful = true;
            username = value['username'];
          }
        });

        if (isLoginSuccessful) {
          Fluttertoast.showToast(
            msg: 'Login berhasil',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(username: username)),
          );
        } else {
          throw Exception('Email atau password salah');
        }
      } else {
        throw Exception('Data pengguna tidak ditemukan');
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
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/LogoBus.jpg',
              height: 100,
            ),
            SizedBox(height: 15.0),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 25.0),
            ElevatedButton(
              onPressed: () {
                loginUser(emailController.text, passwordController.text);
              },
              child: Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 80.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrasiPage()),
                );
              },
              child: Text(
                'Registrasi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.lightBlue,
                padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 80.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
