import 'package:flutter/material.dart';
import 'package:gestion_payements/categories.dart';
import 'package:gestion_payements/auth/profile.dart';
import 'package:gestion_payements/profs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Dashboard.dart';
import 'auth/login.dart';
import 'auth/signup.dart';


void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: SignUpSection(),
      routes: {
        // LandingScreen.id: (context) => LandingScreen(),
        '/home': (context) => LandingScreen(),

        '/': (context) => LoginSection(),
        '/signUp': (context) => SignUpSection(),
        '/logout': (context) => LogoutScreen(),
        '/profs': (context) => Profs(),
        '/profile': (context) => ProfilePage(),
        '/categories': (context) => Categories(),
      },
    );
  }
}






class BottomNav extends StatefulWidget {
  BottomNav({Key ? key}) : super(key: key);

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State  {
  int _selectedIndex = 0;
  void _onItemTapped(int index)  async{

    setState(()   {
      _selectedIndex = index;
    });
    if (index == 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("token")!;
      String role = prefs.getString("role")!;
      String nom = prefs.getString("nom")!;
      print(role);
      Navigator.push(context,  MaterialPageRoute(
        builder: (context) => LandingScreen(role: role,name: nom,), // Passer le rôle ici
      ),);
    }
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => LogoutScreen()));
    }
    if (index == 2) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("token")!;
      String role = prefs.getString("role")!;
      String email = prefs.getString("email")!;
      String nom = prefs.getString("nom")!;
      Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(username: nom,role: role,email: email)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(selectedIconTheme: IconThemeData(color: Colors.black),unselectedItemColor: Colors.black45,
      showUnselectedLabels: true,selectedLabelStyle: TextStyle(color: Colors.orangeAccent),
      unselectedLabelStyle: TextStyle(color: Colors.orangeAccent,),unselectedIconTheme: IconThemeData(color: Colors.black),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.output_sharp),
          label: 'Logout',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_outlined),
          label: 'Profile',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.black54,showSelectedLabels: true,
      onTap: _onItemTapped,
    );
  }
}



