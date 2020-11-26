import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class Semester extends StatefulWidget {
  final String branch;
  Semester({this.branch});
  @override
  _SemesterState createState() => _SemesterState();
}

class _SemesterState extends State<Semester> {
  String _dropDownValue;

  setData()async{


   await Firestore.instance.collection('departments').document(widget.branch).collection('Semesters').document(_dropDownValue).setData({

      "title":_dropDownValue


    });
    Navigator.pop(context);


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
        _dropDownValue==null?Text(""):FlatButton(
            onPressed: (){
              setData();
            },
            child: Icon(Icons.download_done_rounded),
          )
        ],
        title: Text("Add Semester"),
      ),
      body: SafeArea(
        child:  DropdownButton(
          hint: _dropDownValue == null
              ? Text('Semester')
              : Text(
            _dropDownValue,
            style: TextStyle(color: Colors.blue),
          ),
          isExpanded: true,
          iconSize: 30.0,
          style: TextStyle(color: Colors.blue),
          items: ['I Semester', 'II Semester', 'III Semester','IV Semester','V Semester','VI Semester'].map(
                (val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(val),
              );
            },
          ).toList(),
          onChanged: (val) {
            print(val);
            setState(
                  () {
                _dropDownValue = val;
              },
            );
          },
        ),
      ),
    );
  }
}
