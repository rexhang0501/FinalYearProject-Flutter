import 'package:flutter/material.dart';
import 'package:fyp/addSchedule.dart';
import 'package:intl/intl.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/editSchedule.dart';

class ClockPage extends StatefulWidget {
  @override
  _ClockPageState createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: Firestore.instance
                      .collection("schedule")
                      .orderBy("scheduleTime", descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.data.documents.length == 0) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 16, left: 64, right: 64, top: 16),
                            child: Center(
                              child: Text("You don't have any schedule yet :(",
                                  style: TextStyle(fontSize: 15)),
                            ),
                          ),
                          _buildDottedBorder()
                        ],
                      );
                    } else {
                      return ListView.builder(
                          itemCount: snapshot.data.documents.length + 1,
                          itemBuilder: (context, index) {
                            if (index != snapshot.data.documents.length) {
                              return _buildSchedule(
                                  snapshot.data.documents[index]);
                            } else {
                              return _buildDottedBorder();
                            }
                          });
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }

  Container _buildSchedule(DocumentSnapshot data) {
    String _selectedOption = null;
    List<DropdownMenuItem<String>> _dropDownItem() {
      List<String> ddl = ["Edit Schedule", "Delete Schedule"];
      return ddl
          .map((value) => DropdownMenuItem(
                value: value,
                child: Text(value),
              ))
          .toList();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16, left: 64, right: 64, top: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xFF6448FE), Color(0xFF5FC6FF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight),
        borderRadius: BorderRadius.all(Radius.circular(25)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 5,
              offset: Offset(0, 3),
              spreadRadius: 3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 10),
                child: Icon(
                  Icons.label,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  data['name'],
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 10),
            child: Text(
              data['description'],
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Raleway',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 15),
            child: Text(
              DateFormat("MMMM d yyyy").format(
                  DateTime.fromMillisecondsSinceEpoch(data['scheduleTime'],
                      isUtc: true)),
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Raleway',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('hh:mm aa').format(
                      DateTime.fromMillisecondsSinceEpoch(data['scheduleTime'],
                          isUtc: true)),
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Raleway',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: DropdownButton(
                    value: _selectedOption,
                    items: _dropDownItem(),
                    onChanged: (value) {
                      _selectedOption = value;
                      switch (value) {
                        case "Delete Schedule":
                          data.reference.delete();
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12,
                                        right: 12,
                                        top: 36,
                                        bottom: 36),
                                    child: Text(
                                      'Your schedule has been deleted:)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                );
                              });
                          break;
                        case "Edit Schedule":
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: EditSchedule(dataEdit: data),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                );
                              });
                          break;
                      }
                    },
                    hint: Text('Edit/Delete'),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDottedBorder() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 64, right: 64, top: 16),
      child: DottedBorder(
        strokeWidth: 3,
        color: Colors.white,
        radius: Radius.circular(24),
        borderType: BorderType.RRect,
        dashPattern: [5, 4],
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: FlatButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: AddSchedule(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    );
                  });
            },
            child: Column(
              children: [
                Icon(
                  Icons.work_outline_sharp,
                  size: 60,
                  color: Colors.white38,
                ),
                SizedBox(
                  height: 10,
                ),
                Text('Add Schedule',
                    style: TextStyle(
                      color: Colors.white,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
