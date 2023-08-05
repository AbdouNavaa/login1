import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gestion_payements/auth/profile.dart';
import 'package:gestion_payements/auth/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Dashboard.dart';
import '../main.dart';

class LoginSection extends StatefulWidget {
  static const String id = "LoginSection";

  @override
  State<LoginSection> createState() => _LoginSectionState();
}

class _LoginSectionState extends State<LoginSection> {
  var email;

  var password;

  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/2.5,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFf45d27),
                      Color(0xFFf5851f)
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(90)
                  )
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Spacer(),
                  Align(
                    alignment: Alignment.center,
                    child: Icon(Icons.person,
                      size: 90,
                      color: Colors.white,
                    ),
                  ),
                  Spacer(),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 32,
                          right: 32
                      ),
                      child: Text('Login',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height/2,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(top: 62),
              child: Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width/1.2,
                    height: 45,
                    padding: EdgeInsets.only(
                        top: 4,left: 16, right: 16, bottom: 4
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(50)
                        ),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5
                          )
                        ]
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(Icons.email,
                          color: Colors.grey,
                        ),
                        hintText: 'Email',
                      ),
    onChanged: (value) {
    email = value;
    }
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width/1.2,
                    height: 45,
                    margin: EdgeInsets.only(top: 32),
                    padding: EdgeInsets.only(
                        top: 4,left: 16, right: 16, bottom: 4
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(50)
                        ),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5
                          )
                        ]
                    ),
                    child: TextField(
                        decoration: InputDecoration(icon:  IconButton(onPressed: (){
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        }, icon: Icon(hidePassword? Icons.vpn_key_off:Icons.vpn_key,)),hintText:  "Password",),
                        obscureText: hidePassword,
                        onChanged: (value) {
                          password = value;
                        }),
                  ),

                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(
                  //         top: 16, right: 32
                  //     ),
                  //     child: Text('Forgot Password ?',
                  //       style: TextStyle(
                  //           color: Colors.grey
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Spacer(),

                  Container(
                    height: 45,
                    width: MediaQuery.of(context).size.width/1.2,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFf45d27),
                            Color(0xFFf5851f)
                          ],
                        ),
                        borderRadius: BorderRadius.all(
                            Radius.circular(50)
                        )
                    ),
                    child: Center(
                      child: ElevatedButton(
                          onPressed: () async {
                            await login(email, password);
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            String token = prefs.getString("token")!;
                            String role = prefs.getString("role")!;
                            String email1 = prefs.getString("email")!;
                            String id = prefs.getString("id")!;
                            String name = prefs.getString("nom")!;
                            print(name);
                            print(email1);
                            if (token != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LandingScreen(role: role,name: name,), // Passer le rôle ici
                                ),
                              );
                            }
                          },

                          style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15) ),
                              padding: EdgeInsets.only(left: 117,right: 117),backgroundColor:  Color(0xFFf5851f)),
                          // icon: Icon(Icons.save),
                          child: Center(
                            child: Text('Login'.toUpperCase(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),),
                    ),
                  ),
                  SizedBox(height: 15,),

                  Container(
                    height: 45,
                    width: MediaQuery.of(context).size.width/1.2,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFf45d27),
                            Color(0xFFf5851f)
                          ],
                        ),
                        borderRadius: BorderRadius.all(
                            Radius.circular(50)
                        )
                    ),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder:(context) =>  SignUpSection()));
                        },

                          style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15) ),
                              padding: EdgeInsets.only(left: 117,right: 117),backgroundColor: Colors.white,foregroundColor: Colors.black87),
                          // icon: Icon(Icons.save),
                          child: Center(
                            child: Text('Sign Up'.toUpperCase(),
                              style: TextStyle(
                                  // color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

login(email, password) async {
  var url = "http://192.168.43.73:5000/auth/login"; // iOS
  final response = await http.post(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'email': email,
      'password': password,
    }),
  );
  print(response.body);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var parse = jsonDecode(response.body);

  var nom = parse["data"]["user"]["nom"];
  var role = parse["data"]["user"]["role"];
  var id = parse["data"]["user"]["_id"];
  var email1 = parse["data"]["user"]["email"];
  await prefs.setString('token', parse["token"]);
  await prefs.setString('role', role);
  await prefs.setString('id', id);
  await prefs.setString('email', email1);
  await prefs.setString('nom', nom);
  print('Welcom $email1');
}