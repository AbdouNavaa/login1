import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'categories.dart';
import 'main.dart';





class Matieres extends StatefulWidget {
  Matieres({Key ? key}) : super(key: key);

  @override
  _MatieresState createState() => _MatieresState();
}

class _MatieresState extends State<Matieres> {

  Future<List<Matiere>>? futureMatiere;
  // Categories myNewClass = Categories();

  List<Matiere>? filteredItems;

  void DeleteMatiere(id) async{
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String token = prefs.getString("token")!;
    // print(token);

    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/matiere' +"/$id"),
      // headers: {
      //   'Content-Type': 'application/json',
      //   'Authorization': 'Bearer $token',
      // },
      // body: jsonEncode(regBody)
    );

    var jsonResponse = jsonDecode(response.body);
    print(response.statusCode);
    if(response.statusCode ==200){
      fetchMatiere();
    }

  }
  Future<void> UpdateMatiere(String id, String name, String description, String categorieId) async {
    final Map<String, dynamic> data = {
      "name": name,
      "description": description,
      "categorie": categorieId,
    };

    final response = await http.patch(
      Uri.parse('http://192.168.43.73:5000/matiere/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      // Update successful
      print('Matiere mise à jour avec succès');
      // Fetch the updated list of Matieres and update the UI
      fetchMatiere().then((data) {
        setState(() {
          filteredItems = data;
        });
      }).catchError((error) {
        print('Erreur lors de la récupération des Matieres: $error');
      });
    } else {
      print('Erreur lors de la mise à jour de la Matiere. Code d\'état: ${response.statusCode}');
    }
  }


  @override
  void initState() {
    super.initState();
    fetchMatiere().then((data) {
      setState(() {
        filteredItems = data; // Assigner la liste renvoyée par Matiereesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });

  }
  TextEditingController _searchController = TextEditingController();
  TextEditingController _name = TextEditingController();
  TextEditingController _desc = TextEditingController();
  Category? selectedCateg; // initialiser le type sélectionné à null


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        // appBar: AppBar(
        //   title: Center(child: Text(' ${filteredItems?.length} Matiere')),
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
                  List<Matiere> Matieres = await fetchMatiere();

                  setState(() {
                    // Implémentez la logique de filtrage ici
                    // Par exemple, filtrez les Matiereesseurs dont le name ou le préname contient la valeur saisie
                    filteredItems = Matieres!.where((Matiere) =>
                    Matiere.name!.toLowerCase().contains(value.toLowerCase()) ||
                        Matiere.description!.toLowerCase().contains(value.toLowerCase())).toList();
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search by matiere ',
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
                  child: Center(child: Text(' ${filteredItems?.length} Matiere',style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),)))),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: FutureBuilder<List<Matiere>>(
                    future: fetchMatiere(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List<Matiere>? items = snapshot.data;

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
                                      onTap: () async{
                                        List<Category> types =await  fetchCategory() ;
                                        List<Matiere> matieres =await  fetchMatiere() ;
                                        _name.text = items![index].name;
                                        _desc.text = items![index].description;
                                        // selectedCateg = items![index].ca;
                                        List<Category?> selectedCategories = List.generate(matieres.length, (_) => null);

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
                                                        decoration:
                                                        InputDecoration(labelText: 'Name'),
                                                      ),
                                                      TextFormField(
                                                        controller: _desc,
                                                        decoration:
                                                        InputDecoration(labelText: 'Desc'),
                                                      ),

                                                      DropdownButtonFormField<Category>(
                                                        value: selectedCategories[index],
                                                        items: types.map((type) {
                                                          return DropdownMenuItem<Category>(
                                                            value: type,
                                                            child: Text(type.name ?? ''),
                                                          );
                                                        }).toList(),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            selectedCategories[index] = value;
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
                                                    UpdateMatiere(items![index].id!, _name.text, _desc.text,selectedCategories[index]!.id!);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Le Type est  Update avec succès.')),
                                                    );


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
                                              Image.network('https://th.bing.com/th/id/OIP.kmkQcLbHBgOa9qkMMkdGJwHaFM?pid=ImgDet&rs=1', width: 170,
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
                                                              DeleteMatiere(snapshot.data![index].id);
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(content: Text('Le Maitiere a été Supprimer avec succès.')),
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

                                          // SizedBox(width: 10,),
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
                                                '${filteredItems?[index].categorie}', // Utilisez la propriété de Category que vous voulez afficher
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
          tooltip: 'Add Matiere',backgroundColor: Colors.white,
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
    TextEditingController _name = TextEditingController();
    TextEditingController _description = TextEditingController();

    Category? selectedCateg; // initialiser le type sélectionné à null

    List<Category> types =await fetchCategory();

    return showDialog(
    context: context,
    builder: (context) {
    return AlertDialog(
    title: Text('Add Matiere'),
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
    controller: _description,
    keyboardType: TextInputType.text,
    decoration: InputDecoration(
    filled: true,
    fillColor: Colors.white,
    hintText: "description",
    border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10.0)))),
    ),
    DropdownButtonFormField<Category>(
    value: selectedCateg,
    items: types.map((type) {
    return DropdownMenuItem<Category>(
    value: type,
    child: Text(type.name ?? ''),
    );
    }).toList(),
    onChanged: (value) {
    setState(() {
    selectedCateg = value;
    });
    },
    decoration: InputDecoration(
    filled: true,
    fillColor: Colors.white,
    hintText: "Categorie",
    border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
    ),
    ),
    ),


    ElevatedButton(onPressed: (){
    Navigator.of(context).pop();
    // fetchMatiere();
    AddMatiere(_name.text, _description.text,selectedCateg!.id!);
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Le Maitiere a été ajouter avec succès.')),
    );
    setState(() {
      fetchMatiere();
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
}

Future<List<Matiere>> fetchMatiere() async {
  final response = await http.get(
    Uri.parse('http://192.168.43.73:5000/matiere/'),
  );

  print(response.statusCode);
  // print(response.body);

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    List<dynamic> matieresData = jsonResponse['matieres'];

    // print(matieresData);
    List<Matiere> matieres = matieresData.map((item) {
      return Matiere.fromJson(item);
    }).toList();

    print("Matiere List: $matieres");
    return matieres;
  } else {
    throw Exception('Failed to load Matiere');
  }
}

class Matiere {
  late final String id;
  final String name;
  final String description;
  final String categorieId; // Utilisez le type approprié pour l'ID de la catégorie
  final num? categorie; // Vous pouvez conserver cette propriété si nécessaire
  final num? taux;

  Matiere({
    required this.id,
    required this.name,
    required this.description,
    required this.categorieId, // Assurez-vous de passer l'ID de la catégorie ici
    this.taux,
    this.categorie,
  });

  factory Matiere.fromJson(Map<String, dynamic> json) {
    return Matiere(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      categorieId: json['categorie']['_id'], // Assurez-vous que la clé "categorie" existe dans le JSON
      taux: json['taux'] ?? 1,
      categorie: json['categorie']['prix'], // Si vous souhaitez conserver la catégorie complète, vous pouvez la mapper ici
    );
  }
}



void AddMatiere(String name, String description, String? categorieId) async {
  final Map<String, dynamic> data = {
    "name": name,
    "description": description,
  };

  if (categorieId != null) {
    data["categorie"] = categorieId;
  }

  final response = await http.post(
    Uri.parse('http://192.168.43.73:5000/matiere/'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data),
  );

  print(response.statusCode);
  if (response.statusCode == 201) {
    print('Matiere ajoutée avec succès');
  } else {
    print("Quelque chose s'est mal passé");
  }
}



// void UpdateMatiere( id,String name,String description, String? categorieId) async {
//   final Map<String, dynamic> data = {
//     "name": name,
//     "description": description,
//   };
//
//   if (categorieId != null) {
//     data["categorie"] = categorieId;
//   }
//
//   final response = await http.patch(
//     Uri.parse('http://192.168.43.73:5000/matiere/'  + '/$id'),
//     headers: {"Content-Type": "application/json"},
//     body: jsonEncode(data),
//   );
//   print(response.statusCode);
//   if (response.statusCode == 201) {
//     print('Matiere maitre a jour avec succes');
//     return jsonDecode(response.body);
//   } else {
//     return Future.error('Server Error');
//     print(
//         '4e 5asser sa77bi mad5al======================================');
//   }
// }


