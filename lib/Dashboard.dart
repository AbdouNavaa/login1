import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gestion_payements/categories.dart';
import 'package:gestion_payements/matieres.dart';
import 'package:gestion_payements/prof_info.dart';
import 'package:gestion_payements/profs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'Cours.dart';
import 'ProfCours.dart';
import 'auth/login.dart';

class LandingScreen extends StatefulWidget {
  final String? id; // Assurez-vous que le rôle est accessible ici
  final String? role; // Assurez-vous que le rôle est accessible ici
  final String? email; // Assurez-vous que le rôle est accessible ici
  final String? name; // Assurez-vous que le rôle est accessible ici

  LandingScreen({ this.role, this.email, this.id, this.name});
  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
 // Constructeur pour recevoir le rôle
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcom ${widget.name}'),),
      body: Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,

            children: [
              if (widget.role == "user")
              Row(
                children: [
                  Card(
                    elevation: 5,
                    margin: EdgeInsets.only(top: 10),
                    shadowColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfesseurInfoPage(id: widget.id,email: widget.email, role: widget.role),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Image.network('https://th.bing.com/th/id/R.8b167af653c2399dd93b952a48740620?rik=%2fIwzk0n3LnH7dA&pid=ImgRaw&r=0', width: 170,
                            fit: BoxFit.fill,
                            height: 170,),
                          SizedBox(height: 20,),
                          Text("Prof Infos", style: TextStyle(fontSize: 20),),
                          SizedBox(height: 40,)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Card(
                    elevation: 5,
                    margin: EdgeInsets.only(top: 10),
                    shadowColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: InkWell(
                      onTap: () async {
                        // Fetch the prof's courses from the backend
                        try{
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          String token = prefs.getString("token")!;
                          final professorData = await fetchProfessorInfo();
                          String id = professorData['professeur']['_id'];

                          print(id);
                          var response = await http.get(
                            Uri.parse('http://192.168.43.73:5000/professeur/$id/cours'),
                            headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
                          );
                          print(response.body);

                          if (response.statusCode == 200) {
                            List<dynamic> courses = json.decode(response.body)['data']['coursLL'];
                            int coursNum = json.decode(response.body)['data']['countLL'];
                            num heuresTV = json.decode(response.body)['data']['heuresTV'];
                            num sommeTV = json.decode(response.body)['data']['sommeTV'];
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProfCoursesPage(courses: courses, coursNum: coursNum, heuresTV: heuresTV, sommeTV: sommeTV,)),
                            );
                          }
                          else {
                            // Handle error
                            Navigator.pop(context);
                            print('Failed to fetch prof courses. Status Code: ${response.statusCode}');
                          }
                        }catch (err) {
                          Navigator.pop(context);
                          print('Server Error: $err');
                        }
                      },

                      child: Column(
                        children: [
                          Image.network(''
                              'https://th.bing.com/th/id/OIP.jeVfx14-a23XhQnKRmmwpAHaGe?pid=ImgDet&rs=1', width: 170,
                            fit: BoxFit.fill,
                            height: 170,),
                          SizedBox(height: 20,),
                          Text("Coures", style: TextStyle(fontSize: 20),),
                          SizedBox(height: 40,)
                        ],
                      ),
                    ),
                  ),


                ],
              ),
              if (widget.role == "responsable")

                Column(
                  children: [
                    Row(
                      children: [
                        Card(
                          elevation: 5,
                          margin: EdgeInsets.only(top: 10),
                          shadowColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> Categories()));
                            },
                            child: Column(
                              children: [
                                Image.network('https://th.bing.com/th/id/OIP.t-rvhvwxaND8ifSjw_yjFAHaFj?pid=ImgDet&w=191&h=142&c=7&dpr=1.5', width: 170,
                                  fit: BoxFit.fill,
                                  height: 170,),
                                SizedBox(height: 20,),
                                Text("Categories", style: TextStyle(fontSize: 20),),
                                SizedBox(height: 40,)
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        Card(
                          elevation: 5,
                          margin: EdgeInsets.only(top: 10),
                          shadowColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> Matieres()));
                            },
                            child: Column(
                              children: [
                                Image.network(''
                                    'https://th.bing.com/th/id/OIP.kmkQcLbHBgOa9qkMMkdGJwHaFM?pid=ImgDet&rs=1', width: 170,
                                  fit: BoxFit.fill,
                                  height: 170,),
                                SizedBox(height: 20,),
                                Text("Matieres", style: TextStyle(fontSize: 20),),
                                SizedBox(height: 40,)
                              ],
                            ),
                          ),
                        ),

                      ],
                    ),
                    SizedBox(height: 60,),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        SizedBox(width: 5,),
                        Card(
                          elevation: 5,
                          margin: EdgeInsets.only(top: 10),
                          shadowColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: InkWell(
                            onTap: () async {
                              // Fetch the prof's courses from the backend
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              String token = prefs.getString("token")!;
                              // final professorData = await fetchProfessorInfo();
                              // String id = professorData['professeur']['_id'];

                              // print(id);
                              var response = await http.get(
                                Uri.parse('http://192.168.43.73:5000/cours'),
                                headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
                              );
                              print(response.body);

                              if (response.statusCode == 200) {
                                List<dynamic> courses = json.decode(response.body)['data']['coursLL'];
                                int coursNum = json.decode(response.body)['data']['countLL'];
                                num heuresTV = json.decode(response.body)['data']['heuresTV'];
                                num sommeTV = json.decode(response.body)['data']['sommeTV'];
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CoursesPage(courses: courses, coursNum: coursNum, heuresTV: heuresTV, sommeTV: sommeTV,)),
                                );
                              } else {
                                // Handle error
                                print('Failed to fetch prof courses. Status Code: ${response.statusCode}');
                              }
                            },

                            child: Column(
                              children: [
                                Image.network(''
                                    'https://th.bing.com/th/id/OIP.jeVfx14-a23XhQnKRmmwpAHaGe?pid=ImgDet&rs=1', width: 170,
                                  fit: BoxFit.fill,
                                  height: 170,),
                                SizedBox(height: 20,),
                                Text("Coures", style: TextStyle(fontSize: 20),),
                                SizedBox(height: 40,)
                              ],
                            ),
                          ),
                        ),


                      ],
                    ),

                    // SizedBox(height: 60,),
                    // Row(
                    //   children: [
                    //     Card(
                    //       elevation: 5,
                    //       margin: EdgeInsets.only(top: 10),
                    //       shadowColor: Colors.blue,
                    //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    //       child: InkWell(
                    //         onTap: () {
                    //         },
                    //         child: Column(
                    //           children: [
                    //             Image.network('https://th.bing.com/th/id/OIP.8RjbuO5ep8pkiWDJVqK_YwHaFE?pid=ImgDet&rs=1', width: 170,
                    //               fit: BoxFit.fill,
                    //               height: 170,),
                    //             SizedBox(height: 20,),
                    //             Text("Payements", style: TextStyle(fontSize: 20),),
                    //             SizedBox(height: 40,)
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //
                    //   ],
                    // ),
                  ],
                ),

            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(),
    );
  }


}
class LogoutScreen extends StatefulWidget {

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sync_lock,size: 370,),
          Text("You must sign-in to access to this section", style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,fontStyle: FontStyle.italic),),
          SizedBox(height: 15,),
          ElevatedButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('token', '');
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginSection()));
            },
            child: Text("Logout", style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic,fontWeight: FontWeight.w400),),
            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15) ),
                padding: EdgeInsets.only(left: 117,right: 117,top: 10,bottom: 10),backgroundColor: Colors.black,foregroundColor: Colors.white),
          ),

        ],
      ),
      bottomNavigationBar: BottomNav(),
    );
  }
}
