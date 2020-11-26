import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire/register/display_name.dart';
import 'package:flutterfire/widgets/custom_route.dart';

class BirthdayField extends StatefulWidget {
  BirthdayField({Key key}) : super(key: key);

  _BirthdayFieldState createState() => _BirthdayFieldState();
}

class _BirthdayFieldState extends State<BirthdayField> {
  bool isValidBirthday = false;
  var birthday;

  birthdayHandler(value) {
    print(DateTime.now().difference(value).inDays);
    setState(() {
      birthday = value;
      isValidBirthday =
          value != null && DateTime.now().difference(value).inDays > 6570;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
        ),
        body: Container(
          padding: EdgeInsets.only(
            top: 30,
            left: 20,
            right: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'What did you joined University?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'You must be 16 years and above.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                padding: EdgeInsets.only(
                  top: 16,
                  left: 20,
                  right: 20,
                ),
                child: Container(
                  height: 200,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    onDateTimeChanged: (v) => birthdayHandler(v),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            elevation: 0.0,
            child: Icon(Icons.check),
            foregroundColor: Colors.white,
            backgroundColor:
                isValidBirthday ? Colors.blueAccent : Colors.grey[400],
            onPressed: isValidBirthday
                ? () {
                    print(birthday.toIso8601String().substring(0, 10));
                    Navigator.of(context).push(FadeRoute(
                      page: DisplayNameField(
                        birthday: birthday.toIso8601String().substring(0, 10),
                      ),
                    ));
                  }
                : null),
        backgroundColor: Colors.white);
  }
}
