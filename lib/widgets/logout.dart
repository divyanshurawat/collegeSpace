import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterfire/authentication_bloc/authentication_bloc.dart';
import 'package:flutterfire/authentication_bloc/authentication_event.dart';
import 'package:flutterfire/authentication_bloc/authentication_event.dart';
import 'package:flutterfire/authentication_bloc/bloc.dart';

class Logout extends StatelessWidget {
  const Logout({Key key}) : super(key: key);

  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                top: 32.0,
                bottom: 4.0,
                left: 16.0,
                right: 16.0,
              ),
              margin: EdgeInsets.only(top: 32.0),
              decoration: new BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // To make the card compact
                children: <Widget>[
                  Text(
                    "Are you sure?",
                    style: TextStyle(fontSize: 24.0, color: Colors.redAccent),
                  ),
                  SizedBox(height: 24.0),
                  Text(
                    "Do you want to logout?",
                    style: TextStyle(color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.0),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      IconButton(
                        iconSize: 24.0,
                        color: Colors.grey[400],
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      IconButton(
                        color: Colors.red[200],
                        icon: Icon(Icons.done),
                        iconSize: 24,
                        onPressed: () {
                          BlocProvider.of<AuthenticationBloc>(context).add(
                            LoggedOut(),
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
