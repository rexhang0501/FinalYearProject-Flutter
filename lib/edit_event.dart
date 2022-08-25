import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:time_range/time_range.dart';
import 'custom_button.dart';

class EditEventPage extends StatefulWidget {
  DocumentSnapshot dataEdit;
  EditEventPage({Key key, this.dataEdit}) : super(key: key);
  @override
  _EditEventPageState createState() => _EditEventPageState(dataEdit);
}

class _EditEventPageState extends State<EditEventPage> {
  DocumentSnapshot dataEdit;
  _EditEventPageState(this.dataEdit);
  TextEditingController eventnameController = TextEditingController();
  TextEditingController eventdesController = TextEditingController();
  TimeRangeResult _timeRange;

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    final _defaultTimeRange = TimeRangeResult(
      TimeOfDay(hour: 14, minute: 50),
      TimeOfDay(hour: 15, minute: 20),
    );

    @override
    void initState() {
      super.initState();
      _timeRange = _defaultTimeRange;
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Insert New Event Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 25,
            ),
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  labelText: 'Insert New Event Name'),
              controller: eventnameController,
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  labelText: 'Insert New Task Description'),
              controller: eventdesController,
            ),
            SizedBox(
              height: 20,
            ),
            TimeRange(
              fromTitle: Text(
                'From',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              toTitle: Text(
                'To',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              titlePadding: 20,
              textStyle: TextStyle(
                  fontWeight: FontWeight.normal, color: Colors.black87),
              activeTextStyle:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              borderColor: Colors.black,
              backgroundColor: Colors.transparent,
              activeBackgroundColor: Colors.blueAccent,
              firstTime: TimeOfDay(hour: 06, minute: 00),
              lastTime: TimeOfDay(hour: 24, minute: 00),
              initialRange: _timeRange,
              timeStep: 10,
              timeBlock: 30,
              onRangeCompleted: (range) => setState(() => _timeRange = range),
            ),
            if (_timeRange != null)
              Text(
                'Event is From ${_timeRange.start.format(context)} To ${_timeRange.end.format(context)}',
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.bold),
              ),
            SizedBox(
              height: 25,
            ),
            Container(
              alignment: Alignment.bottomRight,
              child: CustomButton(
                onPressed: () {
                  if ((eventnameController.text == '') ||
                      (_timeRange == null)) {
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
                                  'Event Name or Event Time Range cannot be empty :(',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ));
                        });
                  } else {
                    Navigator.of(context).pop();
                    dataEdit.reference
                        .updateData({'name': eventnameController.text});
                    dataEdit.reference
                        .updateData({'description': eventdesController.text});
                    dataEdit.reference.updateData({
                      'eventStartTime': DateTime(now.year, now.month, now.day,
                              _timeRange.start.hour, _timeRange.start.minute)
                          .toUtc()
                          .millisecondsSinceEpoch
                    });
                    dataEdit.reference.updateData({
                      'eventEndTime': DateTime(now.year, now.month, now.day,
                              _timeRange.end.hour, _timeRange.end.minute)
                          .toUtc()
                          .millisecondsSinceEpoch
                    });
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
                                  'Your event has been edited!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ));
                        });
                  }
                },
                buttonText: 'Edit Event',
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
