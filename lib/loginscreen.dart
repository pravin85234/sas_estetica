import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:sas_estetica/showShopsData.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'package:permission_handler/permission_handler.dart';

class Loginscreen extends StatefulWidget {
  @override
  State<Loginscreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<Loginscreen> {
  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }
  bool isloading = false;
  bool isPasswordVisible = false;
  TextEditingController userIdController = new TextEditingController();
  TextEditingController controllerPass = new TextEditingController();
  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;

    if (!status.isGranted) {
      var result = await Permission.location.request();
      if (result.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permission denied')),
        );
      } else if (result.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permission permanently denied. Please enable it from settings.')),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Banner with Logo and App Name
            Container(
              color: Colors.orange,
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  Image.asset('assets/sas.jpg', height: 100), // equivalent to @drawable/imperative
                  SizedBox(height: 10),
                  Text(
                    'Sas Estetica Solutions Private Limited',
                    style: TextStyle(
                      fontSize: 23,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Login Form Card
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: userIdController,
                    decoration: InputDecoration(
                      hintText: 'UserId',
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: controllerPass,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amberAccent,
                      ),
                      onPressed: () {
                        if (userIdController.text.isEmpty || controllerPass.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please enter all fields")),
                          );
                        } else {
                          loginRequest();
                        }
                      },
                      child: Text("Login", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            TextButton(
              onPressed: () {

              },
              child: Text(
                "Powered by www.Sas Estetica Solutions Private Limited.com",
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loginRequest() async {
    try {
      setState(() {
        isloading = true;
      });
      check().then((internet) async {
        if (internet) {
          // var body = jsonEncode({
          //   "username": userIdController,
          //   "password": controllerPass,
          // });

          var body=jsonEncode({"username":"admin","password":"A7ge#hu&dt(wer"});

          var uri = Uri.parse("https://api.prepstripe.com/login");
          await http
              .post(uri, body: body)
              .timeout(const Duration(minutes: 1))
              .then((value) {
                // Navigator.pop(context);
                if (value.statusCode == 200) {
                  var result = jsonDecode(value.body) as Map<String, dynamic>;
                  bool response = result["success"];
                  String message = result["message"];
                  String token = result["token"];
                  if (response && message.toUpperCase() == "LOGIN SUCCESSFUL") {
                    savetoken(token);
                    controllerPass.clear();
                    userIdController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Login Success}")),
                    );
                    Navigator.push(context,MaterialPageRoute(builder: (context){
                      return Showshopsdata();
                    }));

                  }
                } else {
                  // Fluttertoast.showToast(
                  //   msg: "LoginFailed",
                  //   gravity: ToastGravity.BOTTOM,
                  //   toastLength: Toast.LENGTH_SHORT,
                  // );
                }
              });
        } else {
          // Navigator.pop(context);
        }
      });
    } catch (e) {
      // Navigator.pop(context);
      print(e.toString());
    }
  }
  Future<void> login() async {
    bool isConnected = await check();

    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No internet connection")),
      );
      return;
    }
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: userIdController.text.trim(),
        password: controllerPass.text.trim(),
      );

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${e.toString()}")),
      );
    }
  }

  Future<bool> check() async {
    try {
      var connect = await Connectivity().checkConnectivity();
      if (connect == ConnectivityResult.mobile) {
        return true;
      } else if (connect == ConnectivityResult.wifi) {
        return true;
      }
    } catch (e) {
      print(e.toString());
    }
    return false;
  }

  Future<void> savetoken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token_id', token);
  }
}

