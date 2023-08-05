import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'main.dart';





class Categories extends StatefulWidget {
  Categories({Key ? key}) : super(key: key);

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {

  Future<List<Category>>? futureCategory;

  List<Category>? filteredItems;

  void DeleteCategory(id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/categorie' +"/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // body: jsonEncode(regBody)
    );

    var jsonResponse = jsonDecode(response.body);
    print(response.statusCode);
    if(response.statusCode ==200){
      fetchCategory();
    }

  }


  @override
  void initState() {
    super.initState();
    fetchCategory().then((data) {
      setState(() {
        filteredItems = data; // Assigner la liste renvoyée par Categoryesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
  }
  TextEditingController _searchController = TextEditingController();

  TextEditingController _name = TextEditingController();
  TextEditingController _desc = TextEditingController();
  TextEditingController _taux = TextEditingController();
  num _selectedTaux = 500;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        // appBar: AppBar(
        //   title: Center(child: Text(' ${filteredItems?.length} ')),
        // ),
        body: Column(
          children: [
            SizedBox(height: 40,),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) async {
                  List<Category> Categories = await fetchCategory();

                  setState(() {
                    // Implémentez la logique de filtrage ici
                    // Par exemple, filtrez les Categoryesseurs dont le name ou le préname contient la valeur saisie
                    filteredItems = Categories!.where((Category) =>
                    Category.name!.toLowerCase().contains(value.toLowerCase()) ||
                        Category.description!.toLowerCase().contains(value.toLowerCase())).toList();
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Rechercher  ',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),

              )
              ,
            ),
            Container(width: 200,height: 50,
                // color: Colors.black87,
                // margin: EdgeInsets.all(8),
                child: Card(
                    elevation: 5,
                    // margin: EdgeInsets.only(top: 10),
                    shadowColor: Colors.blue,
                    // color: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(' ${filteredItems?.length} Categories',style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),)))),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: FutureBuilder<List<Category>>(
                    future: fetchCategory(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List<Category>? items = snapshot.data;

                          return
                            ListView.builder(
                              itemCount: filteredItems?.length,
                              itemBuilder: (context, int index) {
                                return Container(
                                  height: 150,
                                  margin: EdgeInsets.all(8),
                                  child: Card(
                                    elevation: 5,margin: EdgeInsets.only(top: 10),
                                    shadowColor: Colors.blue,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    child: InkWell(
                                      onTap: () {
                                        _name.text = items![index].name!;
                                        _desc.text = items![index].description!;
                                        _selectedTaux = items![index].prix!;
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("Mise à jour de la tâche"),
                                              content: Form(
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      TextFormField(
                                                        controller: _name,
                                                        decoration: InputDecoration(labelText: 'Name'),
                                                      ),
                                                      TextFormField(
                                                        controller: _desc,
                                                        decoration: InputDecoration(labelText: 'Descreption'),
                                                      ),
                                                      DropdownButtonFormField<num>(
                                                        value: _selectedTaux,
                                                        items: [
                                                          DropdownMenuItem<num>(
                                                            child: Text('500'),
                                                            value: 500,
                                                          ),
                                                          DropdownMenuItem<num>(
                                                            child: Text('900'),
                                                            value: 900,
                                                          ),
                                                        ],
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _selectedTaux = value!;
                                                          });
                                                        },
                                                        decoration: InputDecoration(
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          hintText: "taux",
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: Text("ANNULER"),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text(
                                                    "MISE À JOUR",
                                                    style: TextStyle(color: Colors.blue),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    _taux.text = _selectedTaux.toString();

                                                    fetchCategory();
                                                    // AddCategory(_name.text, _desc.text);
                                                    print(items![index].id!);
                                                    UpdateCateg(items![index].id!, _name.text, _desc.text, _selectedTaux,);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Le Type est mis à jour avec succès.')),
                                                    );

                                                    setState(() {
                                                      fetchCategory();
                                                    });
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },

                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              Image.network('https://th.bing.com/th/id/OIP.t-rvhvwxaND8ifSjw_yjFAHaFj?pid=ImgDet&w=191&h=142&c=7&dpr=1.5', width: 170,
                                                fit: BoxFit.fill,
                                                height: 85,),

                                              SizedBox(height: 5,),
                                              ElevatedButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text("Confirmer la suppression"),
                                                        content: Text(
                                                            "Êtes-vous sûr de vouloir supprimer cet élément ?"),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            child: Text("ANNULER"),
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                          ),
                                                          TextButton(
                                                            child: Text(
                                                              "SUPPRIMER",
                                                              // style: TextStyle(color: Colors.red),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                              DeleteCategory(snapshot.data![index].id);
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(content: Text('Le Category a été Supprimer avec succès.')),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Text('Delete'),
                                                style: ElevatedButton.styleFrom(
                                                    primary: Colors.deepOrangeAccent,padding: EdgeInsets.only(left: 65,right: 65),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                                                ),
                                              ),

                                            ],
                                          ),

                                          SizedBox(width: 10,),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${filteredItems?[index].name}',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Text(
                                                '${filteredItems?[index].description}',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Text(
                                                '${filteredItems?[index].prix}',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                              SizedBox(height: 5,),

                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );

                        }
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          // heroTag: 'uniqueTag',
          tooltip: 'Add Category',
          backgroundColor: Colors.white,
          label: Row(
            children: [Icon(Icons.add,color: Colors.black,)],
          ),
          onPressed: () => _displayTextInputDialog(context),

        ),


      ),
      bottomNavigationBar: BottomNav(),

    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    // TextEditingController _name = TextEditingController();
    // TextEditingController _description = TextEditingController();
    // TextEditingController _prix = TextEditingController();
    // num _selectedTaux = 500;


    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text('Add Category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _name,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "name",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                    ),
                    TextField(
                      controller: _desc,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "description",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                    ),
                    DropdownButtonFormField<num>(
                      value: _selectedTaux,
                      items: [
                        DropdownMenuItem<num>(
                          child: Text('500'),
                          value: 500,
                        ),
                        DropdownMenuItem<num>(
                          child: Text('900'),
                          value: 900,
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedTaux = value!;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "taux",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),


                    ElevatedButton(onPressed: (){
                      Navigator.of(context).pop();
                      // fetchCategory();
                      _taux.text = _selectedTaux.toString();
                      AddCategory(_name.text,_desc.text,num.parse(_taux.text));
                      // AddCategory(_name.text, _desc.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Le Category a été ajouter avec succès.')),
                      );
                      setState(() {
                        fetchCategory();
                      });
                    }, child: Text("Add"),

                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white,  elevation: 10,padding: EdgeInsets.only(left: 95,right: 95),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),)
                  ],
                ),
              )
          );
        });
  }


  void AddCategory (String name,String description,[num? prix]) async {

    // Check if the prix parameter is provided, otherwise use the default value of 100
    if (prix == null) {
      prix = 100;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);
    final response = await http.post(
      Uri.parse('http://192.168.43.73:5000/categorie/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        "name":name,
        "description":description ,
        "prix": prix ,
      }),
    );
    if (response.statusCode == 200) {
      print('Category ajouter avec succes');
    } else {
      print("SomeThing Went Wrong");
    }
  }

  void UpdateCateg( id,String name,String description,[num? prix]) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);
    final response = await http.patch(
      Uri.parse("http://192.168.43.73:5000/categorie" + "/$id"),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        "name":name,
        "description":description ,
        "prix": prix ,
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 201) {
      // Fetch the updated list of Matieres and update the UI
      fetchCategory().then((data) {
        setState(() {
          filteredItems = data;
        });
      }).catchError((error) {
        print('Erreur lors de la récupération des Matieres: $error');
      });
    } else {
      return Future.error('Server Error');
      print(
          '4e 5asser sa77bi mad5al======================================');
    }
  }
}

class Category {
  late final String id;
  final String name;
  final String? description;
  final num? prix;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.prix,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      prix: json['prix'] ?? 100, // Provide a default value of 100 if not provided
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
Future<List<Category>> fetchCategory() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  print(token);

  final response = await http.get(
    Uri.parse('http://192.168.43.73:5000/categorie/'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  print(response.statusCode);
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    List<dynamic> categoriesData = jsonResponse['categories'];

    // print(categoriesData);
    List<Category> categories = categoriesData.map((item) {
      return Category.fromJson(item);
    }).toList();

    print(categories);
    return categories;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Category');
  }
}




