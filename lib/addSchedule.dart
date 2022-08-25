import 'package:flutter/material.dart';
import 'package:fyp/custom_button.dart';
import 'package:fyp/time_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddSchedule extends StatefulWidget {
  @override
  _AddScheduleState createState() => _AddScheduleState();
}

class _AddScheduleState extends State<AddSchedule> {
  final CollectionReference _scheduleCollect =
      Firestore.instance.collection('schedule');
  TextEditingController schedulenameController = TextEditingController();
  TextEditingController scheduledesController = TextEditingController();
  String _selectedTime = 'Select Schedule Time';
  String _selectedDate = 'Select Schedule Date';
  TimeOfDay timepick = TimeOfDay.now();
  DateTime datepick = DateTime.now();

  Future _pickTime() async {
    timepick = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (timepick != null) {
      setState(() {
        _selectedTime = "Schedule Time: ${timepick.format(context)}";
      });
    }
  }

  Future _pickDate() async {
    datepick = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      initialDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (datepick != null) {
      setState(() {
        _selectedDate = "${DateFormat("MMMM d yyyy").format(datepick)}";
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
              'Insert Future Schedule',
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
                  labelText: 'Insert Schedule Name'),
              controller: schedulenameController,
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  labelText: 'Insert Schedule Description'),
              controller: scheduledesController,
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TimePicker(
                icon: Icons.access_time,
                onPressed: _pickTime,
                value: _selectedTime,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TimePicker(
                icon: Icons.calendar_today_outlined,
                onPressed: _pickDate,
                value: _selectedDate,
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Container(
              alignment: Alignment.bottomRight,
              child: CustomButton(
                onPressed: () {
                  if (schedulenameController.text != '' &&
                      datepick != DateTime.now() &&
                      timepick != TimeOfDay.now()) {
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
                                  'Your schedule has been added!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ));
                        });
                    _scheduleCollect.document().setData({
                      'name': schedulenameController.text,
                      'description': scheduledesController.text,
                      'scheduleTime': DateTime(datepick.year, datepick.month,
                              datepick.day, timepick.hour, timepick.minute)
                          .toUtc()
                          .millisecondsSinceEpoch,
                    });
                    setState(() {
                      schedulenameController.text = '';
                      scheduledesController.text = '';
                      _selectedTime = 'Select Schedule Time';
                      _selectedDate = 'Select Schedule Date';
                      timepick = TimeOfDay.now();
                      datepick = DateTime.now();
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
                                  'Schedule Name and Schedule Time cannot be empty :(',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ));
                        });
                  }
                },
                buttonText: 'Add Schedule',
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
