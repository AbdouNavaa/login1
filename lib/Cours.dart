import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gestion_payements/prof_info.dart';
import 'package:gestion_payements/update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Ajout.dart';
import 'categories.dart';
import 'main.dart';
import 'matieres.dart';
// import 'package:multi_select_flutter/multi_select_flutter.dart';


class CoursesPage extends StatefulWidget {
  final List<dynamic> courses;
  final int coursNum;
  final num heuresTV;
  final num sommeTV;
  DateTime? dateDeb;
  DateTime? dateFin;
// Calculate the sums for filtered courses

  CoursesPage({required this.courses, required this.coursNum, required this.heuresTV, required this.sommeTV}) {}



  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  double totalType = 0;
// Calculate totalType based on applied date filters and pagination
  void calculateTotalType() {
    if ((widget.dateDeb != null && widget.dateFin != null) ) {
      // If date filters are applied
      totalType = widget.courses
          .where((course) {
        DateTime courseDate =
        DateTime.parse(course['date'].toString());
        return courseDate.isAtSameMomentAs(widget.dateDeb!.toLocal()) ||
            (courseDate.isAfter(widget.dateDeb!.toLocal()) &&
                courseDate.isBefore(
                    widget.dateFin!.toLocal().add(Duration(days: 1))));
      })
          .map((course) => double.parse(course['TH'].toString()))
          .fold(0, (prev, amount) => prev + amount);
    }
    else if ((widget.dateDeb != null && widget.dateFin == null) || (widget.dateDeb == null && widget.dateFin != null) ) {
      // If date filters are applied
      totalType = 0;
    }
    else {
      // If no date filters are applied
      int startIndex = (currentPage - 1) * coursesPerPage;
      int endIndex = startIndex + coursesPerPage - 1;
      totalType = widget.courses
          .skip(startIndex)
          .take(coursesPerPage)
          .map((course) => double.parse(course['TH'].toString()))
          .fold(0, (prev, amount) => prev + amount);
    }
  }

  TextEditingController _selectedProf = TextEditingController();
  TextEditingController _selectedMatiere = TextEditingController();
  TextEditingController _date = TextEditingController();
  TextEditingController _isSigne = TextEditingController();

@override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void DeleteCours(id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/cours' +"/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // body: jsonEncode(regBody)
    );

    var jsonResponse = jsonDecode(response.body);
    print(response.statusCode);
    if(response.statusCode ==200){
      // fetchCategory();
    }

  }
  bool _selectedSigne = false;


  TextEditingController _searchController = TextEditingController();
  int currentPage = 1;
  int coursesPerPage = 5;
  String searchQuery = '';
  bool sortByDateAscending = true;


  @override
  Widget build(BuildContext context) {
    // Call the method to calculate totalType
    calculateTotalType();
    return Scaffold(
      // appBar: AppBar(title: Center(child: Text('${widget.coursNum} Courses',style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),))),
      body: Column(
        children: [
          SizedBox(height: 30,),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                hintText: 'Search by matiere ',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),



          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  DateTime? selectedDateDeb = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2030),
                  );

                  if (selectedDateDeb != null) {
                    setState(() {
                      widget.dateDeb = selectedDateDeb.toUtc();
                      // totalType = 0; // Reset the totalId
                    });
                  }
                },
                child: Text(widget.dateDeb != null ? DateFormat('yyyy/MM/dd').format(widget.dateDeb!) : 'Select Deb'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black87,foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),

              ),
              Container(width: 50,
                child:Text('total: ${totalType.toStringAsFixed(2)}'),
              ),
              ElevatedButton(
                onPressed: () async {
                  DateTime? selectedDateFin = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2030),
                  );

                  if (selectedDateFin != null) {
                    setState(() {
                      widget.dateFin = selectedDateFin.toUtc();
                      // totalType = 0; // Reset the totalId
                    });
                  }
                },
                child: Text(widget.dateFin != null ? DateFormat('yyyy/MM/dd').format(widget.dateFin!) : 'Select Fin'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black87,foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ],          ),
          SizedBox(height: 10,),
          // Display the calculated sums
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(width: 280,height: 50,
                  // color: Colors.black87,
                  margin: EdgeInsets.all(8),
                  child: Card(
                    elevation: 5,
                    // margin: EdgeInsets.only(top: 10),
                    shadowColor: Colors.blue,
                      // color: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: InkWell(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('Eq. CM: ${widget.heuresTV}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                              Text('Montant Total : ${widget.sommeTV}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Center(child: Text('Num of Courses: ${widget.coursNum}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold))),

                        ],
                      ),
                    ),
                  ),
                ),
                Container(width: 40,height: 40,color: Colors.black87,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        totalType =0;
                        sortByDateAscending = !sortByDateAscending;
                        // Reverse the sorting order when the button is tapped
                        widget.courses.sort((a, b) {
                          DateTime dateA = DateTime.parse(a['date'].toString());
                          DateTime dateB = DateTime.parse(b['date'].toString());
                          // Sort in ascending order if sortByDateAscending is true,
                          // otherwise sort in descending order
                          return sortByDateAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
                        });
                      });
                    },
                    child: Icon(sortByDateAscending ? Icons.arrow_upward : Icons.arrow_downward,color: Colors.white,),
                  ),
                ),

              ],
            ),
          ),


          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: ListView.separated(

                  itemCount: widget.courses.length,
                  itemBuilder: (context, index) {

                    widget.courses.sort((a, b) {
                      DateTime dateA = DateTime.parse(a['date'].toString());
                      DateTime dateB = DateTime.parse(b['date'].toString());
                      return dateA.compareTo(dateB);
                    });
                    Map<String, dynamic> course = widget.courses[index];

                    // Convert the date strings to DateTime objects
                    // Extract course data from the list

                    // Convert the date strings to DateTime objects
                    DateTime courseDate = DateTime.parse(course['date'].toString());
                    // Calculate the index of the last course in the current page
                    int lastIndex = currentPage * coursesPerPage - 1;

                    // Filter courses based on the search query
                    bool isMatch = course['matiere'].toLowerCase().contains(searchQuery.toLowerCase()) ||
                        course['professeur'].toLowerCase().contains(searchQuery.toLowerCase()) ||
                        course['isSigne'].toString().contains(searchQuery.toString());


                    // Check if the current course index is within the current page range and matches the search query
                    if (index <= lastIndex && index >= lastIndex - (coursesPerPage - 1) && isMatch) {
                      // totalType  += double.parse(course['TH'].toString());

                      // Check if the course date falls within the selected date range
                    if ((widget.dateDeb == null || courseDate.isAtSameMomentAs(widget.dateDeb!.toLocal()) || courseDate.isAfter(widget.dateDeb!.toLocal())) &&
                        (widget.dateFin == null || courseDate.isBefore(widget.dateFin!.toLocal().add(Duration(days: 1))) || courseDate.isAtSameMomentAs(widget.dateFin!.toLocal()))) {


    // Show the course item only if it's within the current page range

    return SingleChildScrollView(scrollDirection: Axis.horizontal,
                        child: Dismissible(
                          key: Key(course['_id']), // Provide a unique key for each item
                          direction: DismissDirection.endToStart, // Swipe from right to left to dismiss
                          background: Container(
                            alignment: Alignment.center,
                            color: Colors.white12,
                            child: Icon(Icons.delete, color: Colors.black54),
                          ),
                          confirmDismiss: (direction) async {
                            // Show the confirmation dialog when swiping to delete
                            return await
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Confirmer la suppression"),
                                  content: Text("Êtes-vous sûr de vouloir supprimer cet élément ?"),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text("ANNULER"),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                    ),
                                    TextButton(
                                      child: Text("SUPPRIMER"),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            // When dismissed (swiped to delete), call the delete method here
                            DeleteCours(course['_id']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Le Category a été Supprimer avec succès.')),
                            );
                          },

                          child: Container(
                            width: 340,
                            height: 90,
                            // color: Colors.black12,
                            margin: EdgeInsets.only(left: 8,right: 8),
                            child: Card(
                              elevation: 3,
                              // margin: EdgeInsets.only(top: 10),
                                shadowColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),side: BorderSide(color: Colors.black26)),
                                child: InkWell(

                                  onTap: () async{
                                    return showDialog(
                                      context: context,
                                      builder: (context) {
                                        return UpdateCoursDialog(courses: course,);
                                      },
                                    );
                                  },

                                  child: Column(
                                    children: [
                                      SizedBox(height: 10,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  Text('Matiere: ', style: TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle: FontStyle.italic,
                                                    // color: Colors.lightBlue
                                                  ),),
                                                  Text(course['matiere'], style: TextStyle(
                                                      fontSize: 13.5,
                                                      fontWeight: FontWeight.bold,
                                                      fontStyle: FontStyle.italic,
                                                      color: Colors.lightBlue[400]
                                                  ),),
                                                ],
                                              ),
                                              Row(children: [
                                                Text(
                                                  DateFormat('dd/M/yyyy ||HH:mm||').format(
                                                    DateTime.parse(course['date'].toString()).toLocal(),
                                                  ), style: TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.italic,
                                                  // color: Colors.lightBlue
                                                ),),
                                              ],),
                                              Row(children: [
                                                Text('Taux: ', style: TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.italic,
                                                  // color: Colors.lightBlue
                                                ),),
                                                Text(
                                                  course['prix'].toString(), style: TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.italic,
                                                  // color: Colors.lightBlue
                                                ),),
                                              ],),
                                            ],),
                                          // SizedBox(child: Container(
                                          //   color: Colors.black12, width: 5, height: 260,)),

                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  Text('Prof: ', style: TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle: FontStyle.italic,
                                                    // color: Colors.lightBlue
                                                  ),),
                                                  Text(course['professeur'], style: TextStyle(
                                                      fontSize: 13.5,
                                                      fontWeight: FontWeight.bold,
                                                      fontStyle: FontStyle.italic,
                                                      color: Colors.lightBlue[400]
                                                  ),),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text('CM: ${course['CM'].toString()}' , style: TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle: FontStyle.italic,
                                                    // color: Colors.lightBlue
                                                  ),),
                                                  Text('||TP: ${course['TP'].toString()}' , style: TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle: FontStyle.italic,
                                                    // color: Colors.lightBlue
                                                  ),),
                                                  Text('||TD: ${course['TD'].toString()}' , style: TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle: FontStyle.italic,
                                                    // color: Colors.lightBlue
                                                  ),),
                                                ],
                                              ),

                                              Row(
                                                children: [
                                                  Text('Eq.CM : ', style: TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle: FontStyle.italic,
                                                    // color: Colors.lightBlue
                                                  ),),
                                                  Text(course['TH'].toString(), style: TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle: FontStyle.italic,
                                                    // color: Colors.lightBlue
                                                  ),),

                                                ],
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Row( mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            course['isSigne']? 'Signed':'Unsigned', style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic,
                                              color: course['isSigne'] ? Colors.green : Colors.red,
                                          ),),
                                        ],),
                                    ],
                                  ),
                                )
                            ),
                          ),
                        ),
                      );
                    }

                  }else {
                      // Return an empty container as a separator between pages
                      return Container();
                    }},   separatorBuilder: (context, index) => Divider(), // Add a divider between courses
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (currentPage > 1) {
                      currentPage--;
                      // totalType = 0;
                    }
                  });
                },
                child: Text('Previous'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white,foregroundColor: Colors.black),
              ),
              Container(width: 50,child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(currentPage.toString() ),
                  Text('/'),
                  Text(  (widget.courses.length / coursesPerPage).ceil().toString()),
                ],
              )),
              ElevatedButton(
                onPressed: () {
                  int totalPage = (widget.courses.length / coursesPerPage).ceil();
                  setState(() {
                    if (currentPage < totalPage) {
                      currentPage++;
                      // totalType = 0;
                    }
                  });
                },
                child: Container(padding: EdgeInsets.only(left: 12,right: 12),child: Text('Next')),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white,foregroundColor: Colors.black),
              ),
            ],
          ),

        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        // heroTag: 'uniqueTag',
        tooltip: 'Add Cours',backgroundColor: Colors.white,
        label: Row(
          children: [Icon(Icons.add,color: Colors.black,)],
        ),
        onPressed: () => _displayTextInputDialog(context),

      ),

      bottomNavigationBar: BottomNav(),
    );

  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AddCoursDialog();
      },
    );
  }

}