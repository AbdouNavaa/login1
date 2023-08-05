import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gestion_payements/prof_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'matieres.dart';
// import 'package:multi_select_flutter/multi_select_flutter.dart';


class ProfCoursesPage extends StatefulWidget {
  final List<dynamic> courses;

  final int coursNum;
  final num heuresTV;
  final num sommeTV;
  DateTime? dateDeb;
  DateTime? dateFin;
// Calculate the sums for filtered courses

  ProfCoursesPage({required this.courses, required this.coursNum, required this.heuresTV, required this.sommeTV}) {}



  @override
  State<ProfCoursesPage> createState() => _ProfCoursesPageState();
}

class _ProfCoursesPageState extends State<ProfCoursesPage> {
  double totalType = 0;
  void calculateTotalType() {
    if (widget.dateDeb != null && widget.dateFin != null) {
      // If date filters are applied
      totalType = widget.courses
          .where((course) {
        DateTime courseDate =
        DateTime.parse(course['TH'].toString());
        return courseDate.isAtSameMomentAs(widget.dateDeb!.toLocal()) ||
            (courseDate.isAfter(widget.dateDeb!.toLocal()) &&
                courseDate.isBefore(
                    widget.dateFin!.toLocal().add(Duration(days: 1))));
      })
          .map((course) => double.parse(course['types'].toString()))
          .fold(0, (prev, amount) => prev + amount);
    }
    else if ((widget.dateDeb != null && widget.dateFin == null) || (widget.dateDeb == null && widget.dateFin != null) ) {
      // If date filters are applied
      totalType = 0;
    }else {
      // If no date filters are applied
      int startIndex = (currentPage - 1) * coursesPerPage;
      int endIndex = startIndex + coursesPerPage - 1;
      totalType = widget.courses
          .skip(startIndex)
          .take(coursesPerPage)
          .map((course) => double.parse(course['types'].toString()))
          .fold(0, (prev, amount) => prev + amount);
    }
  }


  TextEditingController _date = TextEditingController();

  int currentPage = 1;
  int coursesPerPage = 3;
  String searchQuery = '';
  bool sortByDateAscending = true;




  @override
  Widget build(BuildContext context) {
    calculateTotalType();
    return Scaffold(
      // appBar: AppBar(title:
      // Center(child: Text('${widget.coursNum} Courses',
      //   style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold,color: Colors.white),),)),
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
                        // totalType =0;
                        sortByDateAscending = !sortByDateAscending;
                        // Reverse the sorting order when the button is tapped
                        widget.courses.sort((a, b) {
                          DateTime dateA = DateTime.parse(a['TH'].toString());
                          DateTime dateB = DateTime.parse(b['TH'].toString());
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
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: ListView.separated(
    itemCount: widget.courses.length,
    itemBuilder: (context, index) {
      // Extract course data from the list
      widget.courses.sort((a, b) {
        DateTime dateA = DateTime.parse(a['TH'].toString());
        DateTime dateB = DateTime.parse(b['TH'].toString());
        return dateA.compareTo(dateB);
      });  Map<String, dynamic> course = widget.courses[index];


      // Convert the date strings to DateTime objects
      DateTime courseDate = DateTime.parse(course['TH'].toString());

    // DateTime courseDate = DateTime.parse(course['date'].toString());
    // Calculate the index of the last course in the current page
    int lastIndex = currentPage * coursesPerPage - 1;

      bool isMatch = course['matiere'].toLowerCase().contains(searchQuery.toLowerCase());


      // Check if the current course index is within the current page range and matches the search query
      if (index <= lastIndex && index >= lastIndex - (coursesPerPage - 1) && isMatch) {
        // totalType  += double.parse(course['types'].toString());

        // Check if the course date falls within the selected date range
      // Check if the course date falls within the selected date range
    if ((widget.dateDeb == null || courseDate.isAtSameMomentAs(widget.dateDeb!.toLocal()) || courseDate.isAfter(widget.dateDeb!.toLocal())) &&
    (widget.dateFin == null || courseDate.isBefore(widget.dateFin!.toLocal().add(Duration(days: 1))) || courseDate.isAtSameMomentAs(widget.dateFin!.toLocal()))) {

    // totalType  += double.parse(course['types'].toString());
        return Container(
          width: 340,
          height: 110,
          // color: Colors.black12,
          margin: EdgeInsets.only(left: 8,right: 8),
          child: Card(
              elevation: 3,
              // margin: EdgeInsets.only(top: 10),
              shadowColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),side: BorderSide(color: Colors.black26)),
              child: InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text('', style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              // color: Colors.lightBlue
                            ),),
                            Text(course['matiere'], style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                // color: Colors.lightBlue[400]
                            ),),
                          ],
                        ),
                        Row(children: [
                          Text('', style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            // color: Colors.lightBlue
                          ),),
                          Text(
                            DateFormat('dd/M/yyyy || HH:mm').format(
                              DateTime.parse(course['TH'].toString()).toLocal(),
                            ), style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            // color: Colors.lightBlue
                          ),),
                        ],),
                        Row(children: [
                          Text('Taux: ', style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            // color: Colors.lightBlue
                          ),),
                          Text(
                            ' ${course['somme'].toString()}' , style: TextStyle(
                            fontSize: 16.5,
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
                            Text('', style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              // color: Colors.lightBlue
                            ),),
                            Row(
                              children: [
                                Text('CM: ${course['debit'].toString()}' , style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                  // color: Colors.lightBlue
                                ),),
                                Text(',TP: ${course['TD'].toString()}' , style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                  // color: Colors.lightBlue
                                ),),
                              ],
                            ),

                          ],
                        ),
                        Row(

                          children: [
                            Text('', style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              // color: Colors.lightBlue
                            ),),
                            Text('TD: ${course['CM'].toString()}' , style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              // color: Colors.lightBlue
                            ),),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Eq.CM : ', style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              // color: Colors.lightBlue
                            ),),
                            Text(course['types'].toString(), style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                                // color: Colors.lightBlue[400]
                            ),),

                          ],
                        ),
                      ],
                    )
                  ],
                ),
              )
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
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (currentPage > 1) {
                      // totalType =0;
                      currentPage--;
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
                      // totalType =0;
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
    List<Map<String, dynamic>> selectedTypes = [];

    List<Map<String, dynamic>> availableTypes = [
      {"name": "CM", "nbh": 1.5},
      {"name": "CM", "nbh": 2},
      {"name": "TP", "nbh": 1.5},
      {"name": "TP", "nbh": 1},
      {"name": "TD", "nbh": 1.5},
      {"name": "TD", "nbh": 1},
      // Add more available types here as needed
    ];

    final professorData = await fetchProfessorInfo();
    String professorId = professorData['professeur']['_id'];
    List<dynamic> professorMatieres = professorData['professeur']['matieres'];


    Matiere? selectedMat;

    DateTime? selectedDateTime; // Initialize the selected date and time to null
    Future<void> selectTime(TextEditingController controller) async {
      DateTime? selectedDateTime = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2030),
      );

      if (selectedDateTime != null) {
        TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (selectedTime != null) {
          DateTime selectedDateTimeWithTime = DateTime(
            selectedDateTime.year,
            selectedDateTime.month,
            selectedDateTime.day,
            selectedTime.hour,
            selectedTime.minute,
          );

          String formattedDateTime = DateFormat('yyyy/MM/dd HH:mm').format(selectedDateTimeWithTime);
          setState(() {
            controller.text = formattedDateTime;
          });
        }
      }
    }

    return showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text('Add Cours Au Prof'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(height: 110,
                  child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                    child: Row(
                      children: availableTypes.map((type) {
                        return CheckboxMenuButton(
                          value: selectedTypes.contains(type),
                          onChanged: (value) {
                            setState(() {
                              if (selectedTypes.contains(type)) {
                                selectedTypes.remove(type);
                              } else {
                                selectedTypes.add(type);
                              }
                            });
                          },child: Text(type['name'] + ' - ' + type['nbh'].toString()),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                SizedBox(height: 16),
                Text(
                  'Select Matiere:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                DropdownButtonFormField<Matiere>(
                  value: selectedMat,
                  items: professorMatieres.map((matiere) {
                    return DropdownMenuItem<Matiere>(
                      value: Matiere(
                        id: matiere['_id'],
                        name: matiere['name'], description: matiere['description'], categorieId: matiere['categorie']['_id'],
                        // Add other properties if needed
                      ),
                      child: Text(matiere['name'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMat = value;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Select Matiere", // Update the hintText
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),


                SizedBox(height: 16),
                TextFormField(
                  controller: _date,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  // readOnly: true,
                  onTap: () => selectTime(_date),
                ),


                // ElevatedButton for adding the matiere to professor
                ElevatedButton(
                  onPressed: () async {
                    if (selectedMat == null ) {

                      // Check if both a matiere and at least one type is selected
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a matiere .')),
                      );
                    }
                    else if (selectedTypes.isEmpty) {

                      // Check if both a matiere and at least one type is selected
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select  at least one type.')),
                      );
                    }
                    else if (_date == null) {

                      // Check if both a matiere and at least one type is selected
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a date.')),
                      );
                    }
                    else {
                      Navigator.of(context).pop();
                      // SharedPreferences prefs = await SharedPreferences.getInstance();
                      // String token = prefs.getString("token")!;

                      print(professorId);
                      print(selectedMat!.id!);
                      print(selectedTypes); // Check the selected types here

                      DateTime date = DateFormat('yyyy/MM/dd HH:mm').parse(_date.text).toUtc();
                      // Pass the selected types to addCoursToProfesseur method
                      addCoursToProfesseur( selectedMat!.id!, selectedTypes, date);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Matiere has been added to professor successfully.')),
                      );

                      // setState(() {
                      //   fetchProfessorInfo();
                      // });
                    }
                  },
                  child: Text("Add"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 10,
                    padding: EdgeInsets.only(left: 95, right: 95),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Future<void> addCoursToProfesseur( String matiereId, List<Map<String, dynamic>> types, DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    final professorData = await fetchProfessorInfo();
    String id = professorData['professeur']['_id'];
    final url = 'http://192.168.43.73:5000/professeur/$id/cours';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = json.encode({
      'matiere': matiereId,
      'type': types,
      'date': date.toIso8601String(),
    });

    final response = await http.post(Uri.parse(url), headers: headers, body: body);
print(response.statusCode);
    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      Navigator.of(context).pop(true);

      // You can handle the response data here if needed
      print(responseData);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Course added successfully.')),
      // );
    } else {
      // Handle errors
      print('Failed to add course to professor. Status Code: ${response.statusCode}');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to add course to professor.')),
      // );
    }
  }


  Future<List<Matiere>> fetchMatiereCateg(String categoryId) async {
    final url = 'http://192.168.43.73:5000/categorie/$categoryId/matieres';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Matiere> matieres = List<Matiere>.from(data['matieres'].map((m) => Matiere.fromJson(m)));
      return matieres;
    } else {
      throw Exception('Failed to fetch matières');
    }
  }
}
