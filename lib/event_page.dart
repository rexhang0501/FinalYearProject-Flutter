import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fyp/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/edit_event.dart';
import 'package:intl/intl.dart';
import './main.dart';

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('event')
            .orderBy('eventStartTime', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.data.documents.length == 0) {
            return Center(
              child: Text('You dont have event for today :D',
                  style: TextStyle(fontSize: 15)),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                return _buildEvent(snapshot.data.documents[index]);
              },
            );
          }
        });
  }

  Widget _buildEvent(DocumentSnapshot data) {
    //Calculate Notification Popout Time
    String hour = DateFormat('HH').format(DateTime.fromMillisecondsSinceEpoch(
        data['eventStartTime'],
        isUtc: true));
    String minute = DateFormat('mm').format(DateTime.fromMillisecondsSinceEpoch(
        data['eventStartTime'],
        isUtc: true));
    int calculateMinute = int.parse(minute);
    int calculateHour = int.parse(hour);
    if (calculateMinute >= 15) {
      calculateMinute = calculateMinute - 15;
      calculateMinute.toString();
      calculateHour.toString();
    } else {
      calculateMinute = calculateMinute + 45;
      calculateHour = calculateHour - 1;
      calculateHour.toString();
      calculateMinute.toString();
    }
    //Set Notification Time
    Cron cron = Cron();
    cron.schedule(new Schedule.parse('$calculateMinute $calculateHour * * *'),
        () async {
      taskReminder(DateTime.now(), data['name'], data['description']);
    });

    //Event Reset Function
    cron.schedule(new Schedule.parse('55 23 * * *'), () async {
      data.reference.delete();
    });

    return InkWell(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Modify the event:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Text(
                      data['name'],
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      data['description'],
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      DateFormat('hh:mm aa').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              data['eventStartTime'],
                              isUtc: true)),
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      'Until',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      DateFormat('hh:mm aa').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              data['eventEndTime'],
                              isUtc: true)),
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: EditEventPage(
                                      dataEdit: data,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                    ),
                                  );
                                });
                          },
                          buttonText: 'Edit Event',
                          color: Colors.blueAccent,
                          textColor: Colors.white,
                        ),
                        CustomButton(
                          onPressed: () {
                            data.reference.delete();
                            Navigator.of(context).pop();
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16,
                                            right: 16,
                                            top: 40,
                                            bottom: 40),
                                        child: Text(
                                          'Your event has been deleted!',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ));
                                });
                          },
                          buttonText: 'Delete',
                          color: Colors.red,
                          textColor: Colors.white,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Row(
          children: [
            Column(
              children: [
                Container(
                    width: 75,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 10.0,
                      ),
                      child: Text(DateFormat('hh:mm aa').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              data['eventStartTime'],
                              isUtc: true))),
                    )),
                Container(height: 30, width: 3, color: Colors.blueGrey),
                Container(
                    width: 75,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 10.0,
                      ),
                      child: Text(DateFormat('hh:mm aa').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              data['eventEndTime'],
                              isUtc: true))),
                    )),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8, left: 10),
                child: Container(
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black38,
                          blurRadius: 5,
                          offset: Offset(0, 3)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'],
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 12,
                      ),
                      Text(data['description']),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void taskReminder(DateTime scheduledNotificationDateTime, String eventName,
      String eventDes) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_notif',
      'alarm_notif',
      'channelDescription',
      icon: '@drawable/app_icon',
      largeIcon: DrawableResourceAndroidBitmap('@drawable/app_icon'),
      channelShowBadge: true,
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.schedule(
        0,
        'Remember your event: $eventName !',
        eventDes,
        scheduledNotificationDateTime,
        platformChannelSpecifics);
  }
}
