import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fyp/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/edit_task.dart';
import 'package:intl/intl.dart';
import 'main.dart';

var score = 50;

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  @override
  Widget build(BuildContext context) {
    Cron cron = Cron();
    cron.schedule(new Schedule.parse('0 8 * * *'), () async {
      taskReminder(
          DateTime.now(), 'Update Schedule for today:))', 'Make Appointment!');
    });
    cron.schedule(new Schedule.parse('57 11 * * *'), () async {
      final QuerySnapshot qSnap =
          await Firestore.instance.collection('task').getDocuments();
      final int documents = qSnap.documents.length;
      if (documents == 0) {
        setState(() {
          score = score - 10;
        });
      } else {
        setState(() {
          score = score + 10;
        });
      }
    });

    return StreamBuilder(
        stream: Firestore.instance
            .collection('task')
            .orderBy('dueTime', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.data.documents.length == 0) {
            return Center(
              child: Text('You dont have any task for today :(',
                  style: TextStyle(fontSize: 15)),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                return _taskFinish(snapshot.data.documents[index]);
              },
            );
          }
        });
  }

  Widget _taskFinish(DocumentSnapshot data) {
    // final _score = Firestore.instance.collection('userScore').snapshots();

    //Calculate Notification Popout Time

    String hour = DateFormat('HH').format(
        DateTime.fromMillisecondsSinceEpoch(data['dueTime'], isUtc: true));
    String minute = DateFormat('mm').format(
        DateTime.fromMillisecondsSinceEpoch(data['dueTime'], isUtc: true));
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

    Cron cron = Cron();

    //Task Notication
    if (data['isFinish'] == false) {
      cron.schedule(new Schedule.parse('$calculateMinute $calculateHour * * *'),
          () async {
        taskReminder(DateTime.now(), data['name'], data['description']);
      });
    }

    //Task Reset Function
    cron.schedule(new Schedule.parse('59 23 * * *'), () async {
      data.reference.delete();
    });

    cron.schedule(new Schedule.parse('$minute $hour * * *'), () async {
      if (data['isFinish'] == false) {
        score = score - 5;
      }
    });

    //Build Task List
    if (data['isFinish'] == false) {
      return InkWell(
        onTap: () {
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
                        'Mark task as completed:',
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
                            DateTime.fromMillisecondsSinceEpoch(data['dueTime'],
                                isUtc: true)),
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        data['priority'],
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      CustomButton(
                        onPressed: () {
                          data.reference.updateData({'isFinish': true});
                          score = score + 5;
                          Navigator.pop(context);
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
                                          left: 16,
                                          right: 16,
                                          top: 40,
                                          bottom: 40),
                                      child: Text(
                                        'Task marked as completed!',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ));
                              });
                        },
                        buttonText: 'Confirm',
                        color: Colors.blue,
                        textColor: Colors.white,
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
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
                        'Modify the task:',
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
                            DateTime.fromMillisecondsSinceEpoch(data['dueTime'],
                                isUtc: true)),
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        data['priority'],
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
                                      child: EditTaskPage(
                                        dataEdit: data,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                    );
                                  });
                            },
                            buttonText: 'Edit Task',
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
                                            'Your task has been deleted!',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ));
                                  });
                            },
                            buttonText: 'Delete',
                            color: Colors.redAccent,
                            textColor: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 25.0, top: 10, bottom: 10),
          child: Row(
            children: [
              Icon(
                Icons.radio_button_unchecked,
                color: Colors.blue,
                size: 23,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(DateFormat('hh:mm aa').format(
                    DateTime.fromMillisecondsSinceEpoch(data['dueTime'],
                        isUtc: true))),
              ),
              SizedBox(
                width: 26,
              ),
              Expanded(
                child: Container(
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
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          data['priority'],
                          style: TextStyle(
                              fontSize: 15, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        foregroundDecoration: BoxDecoration(color: Color(0x60FDFDFD)),
        child: Padding(
          padding: const EdgeInsets.only(left: 25.0, top: 10, bottom: 10),
          child: Row(
            children: [
              Icon(
                Icons.radio_button_checked,
                color: Colors.blue,
                size: 23,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(DateFormat('hh:mm aa').format(
                    DateTime.fromMillisecondsSinceEpoch(data['dueTime'],
                        isUtc: true))),
              ),
              SizedBox(
                width: 26,
              ),
              Expanded(
                child: Container(
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
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          data['priority'],
                          style: TextStyle(
                              fontSize: 15, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  //Pop Notification Function
  void taskReminder(DateTime scheduledNotificationDateTime, String taskName,
      String taskDes) async {
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

    await flutterLocalNotificationsPlugin.schedule(0, 'Remember to $taskName',
        taskDes, scheduledNotificationDateTime, platformChannelSpecifics);
  }
}
