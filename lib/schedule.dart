import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fyp/task_page.dart';
import 'package:fyp/add_task.dart';
import 'package:fyp/event_page.dart';
import 'package:fyp/add_event.dart';
import 'package:fyp/custom_button.dart';

class DailySchedule extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DailyScheduleState();
  }
}

class _DailyScheduleState extends State<DailySchedule> {
  PageController _pageController = PageController();
  double currentPage = 0;

  @override
  Widget build(BuildContext context) {
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page;
      });
    });

    DateTime date = DateTime.now();

    String _dayCount(int dateCount) {
      switch (dateCount) {
        case 1:
          return 'Monday';
        case 2:
          return 'Tuesday';
        case 3:
          return 'Wednesday';
        case 4:
          return 'Thrusday';
        case 5:
          return 'Friday';
        case 6:
          return 'Saturday';
        case 7:
          return 'Sunday';
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF5FC6FF), Color(0xFF6448FE)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight),
            ),
          ),
          _buildSchedule(_dayCount, date, context),
          _viewScore(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    child: currentPage == 0 ? AddTaskPage() : AddEventPage(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  );
                });
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.blueAccent),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Column _buildSchedule(
      String _dayCount(int dateCount), DateTime date, BuildContext context) {
    String formatDate(DateTime date) => DateFormat("MMMM d").format(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.only(
            left: 24,
          ),
          child: Text(
            _dayCount(date.weekday),
            style: TextStyle(fontSize: 38, color: Colors.white),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Text(
            formatDate(date),
            style: TextStyle(
                fontSize: 40, color: Colors.black45, fontFamily: 'Raleway'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: _button(context),
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            children: [
              TaskPage(),
              EventPage(),
            ],
          ),
        )
      ],
    );
  }

  Widget _button(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: CustomButton(
            buttonText: 'Task',
            textColor:
                currentPage == 0 ? Colors.white : Theme.of(context).accentColor,
            color:
                currentPage == 0 ? Theme.of(context).accentColor : Colors.white,
            borderColor:
                currentPage == 0 ? Colors.white : Theme.of(context).accentColor,
            onPressed: () {
              _pageController.previousPage(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.bounceInOut);
            },
          ),
        ),
        SizedBox(
          width: 50,
        ),
        Expanded(
          child: CustomButton(
            buttonText: 'Event',
            textColor:
                currentPage == 1 ? Colors.white : Theme.of(context).accentColor,
            color:
                currentPage == 1 ? Theme.of(context).accentColor : Colors.white,
            borderColor:
                currentPage == 1 ? Colors.white : Theme.of(context).accentColor,
            onPressed: () {
              _pageController.nextPage(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.bounceInOut);
            },
          ),
        ),
      ],
    );
  }

  Widget _viewScore() {
    return Container(
      alignment: Alignment.topRight,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: Text(
                'Score:',
                style: TextStyle(
                    fontSize: 38, fontFamily: 'Raleway', color: Colors.white70),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: Text(
                '$score',
                style: TextStyle(
                    fontSize: 38, fontFamily: 'Raleway', color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*StreamBuilder(
                  stream:
                      Firestore.instance.collection('userScore').snapshots(),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data.documents[0]['score'].toString(),
                      style: TextStyle(
                          fontSize: 38,
                          fontFamily: 'Raleway',
                          color: Colors.white70),
                    );
                  }),*/
