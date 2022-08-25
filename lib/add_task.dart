import 'package:flutter/material.dart';
import 'package:fyp/custom_button.dart';
import 'package:fyp/time_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTaskPage extends StatefulWidget {
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final CollectionReference _taskCollect =
      Firestore.instance.collection('task');
  TextEditingController tasknameController = TextEditingController();
  TextEditingController taskdesController = TextEditingController();
  String dropdownValue = 'Urgent & Important';
  String _selectedTime = 'Select Task Due Time';
  TimeOfDay timepick = TimeOfDay.now();
  DateTime now = DateTime.now();

  Future _pickTime() async {
    timepick = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (timepick != null) {
      setState(() {
        _selectedTime = "Due Time: ${timepick.format(context)}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Insert Task',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  labelText: 'Insert Task Name'),
              controller: tasknameController,
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  labelText: 'Insert Task Description'),
              controller: taskdesController,
            ),
            SizedBox(
              height: 20,
            ),
            DropdownButton<String>(
              value: dropdownValue,
              icon: Icon(Icons.arrow_drop_down_circle),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.blueAccent),
              underline: Container(
                height: 2,
                color: Colors.blueAccent,
              ),
              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
              },
              items: <String>[
                'Urgent & Important',
                'Urgent & UnImportant',
                'Important & NonUrgent ',
                'UnImportant & NonUrgent',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(
              height: 20,
            ),
            TimePicker(
              icon: Icons.access_time,
              onPressed: _pickTime,
              value: _selectedTime,
            ),
            SizedBox(
              height: 25,
            ),
            Container(
              alignment: Alignment.bottomRight,
              child: CustomButton(
                onPressed: () {
                  if (tasknameController.text == '' ||
                      timepick == TimeOfDay.now()) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 40, bottom: 40),
                                child: Text(
                                  'Task name and Task Due Time cannot be empty :(',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ));
                        });
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 40, bottom: 40),
                                child: Text(
                                  'Your task has been added!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ));
                        });
                    _taskCollect.document().setData({
                      'name': tasknameController.text,
                      'description': taskdesController.text,
                      'priority': dropdownValue,
                      'isFinish': false,
                      'dueTime': DateTime(now.year, now.month, now.day,
                              timepick.hour, timepick.minute)
                          .toUtc()
                          .millisecondsSinceEpoch,
                    });
                    setState(() {
                      tasknameController.text = '';
                      taskdesController.text = '';
                      _selectedTime = 'Select Task Due Time';
                      timepick = TimeOfDay.now();
                    });
                  }
                },
                buttonText: 'Add Task',
                color: Theme.of(context).accentColor,
                textColor: Colors.white,
                borderColor: Theme.of(context).accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
