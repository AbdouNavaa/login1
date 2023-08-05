import 'package:flutter/material.dart';

import '../main.dart';

class ProfilePage extends StatefulWidget {
  final String? username;
  final String? role;
  final String? email;

  ProfilePage({this.role, this.email, this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage(
                    'https://th.bing.com/th/id/R.8b167af653c2399dd93b952a48740620?rik=%2fIwzk0n3LnH7dA&pid=ImgRaw&r=0'),
              ),
              SizedBox(height: 20),
             Container(
               margin: EdgeInsets.all(20),
               height: 350,
               child: Card(shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(20)),
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: [
                     SizedBox(height: 30,),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       children: [
                         Icon(Icons.perm_identity_sharp, size: 30,),
                         Text(
                           "Username: ",
                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                         ),
                         Text(
                           widget.username.toString(),
                           style: TextStyle(fontSize: 18),
                         ),
                       ],
                     ),
                     SizedBox(height: 20),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       children: [
                         Icon(Icons.workspace_premium, size: 30,),
                         Text(
                           "Role: ",
                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                         ),
                         Text(
                           widget.role!,
                           style: TextStyle(fontSize: 18),
                         ),
                       ],
                     ),
                     SizedBox(height: 10),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       children: [
                         Icon(Icons.alternate_email_sharp, size: 30,),
                         Text(
                           "Email: ",
                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                         ),
                         Text(
                           widget.email!,
                           style: TextStyle(fontSize: 18),
                         ),
                       ],
                     ),
                   ],
                 ),
               ),
             )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(),
    );
  }
}
