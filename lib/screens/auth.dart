import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterfire/authentication_bloc/bloc.dart';
import 'package:flutterfire/login/facebook_login_button.dart';
import 'package:flutterfire/login/login.dart';
import 'package:flutterfire/login/login_screen.dart';
import 'package:flutterfire/login/phone_auth_screen.dart';
import 'package:flutterfire/register/birthday_field.dart';
import 'package:flutterfire/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterfire/widgets/custom_route.dart';

/// Responsible for The auth screen
/// Used bloc listner to handle facebook and google login states

class AuthScreen extends StatelessWidget {
  final UserRepository _userRepository;

  AuthScreen({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    double height = MediaQuery.of(context).size.height;
    final _loginBloc = BlocProvider.of<LoginBloc>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(context,
              SlideTopRoute(page: BirthdayField()));

        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                text: "Don't have an account?",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text: " Sign Up",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w900),
              )
            ]),
          ),
        ),
      ),
      body: BlocListener(
        bloc: _loginBloc,
        listener: (BuildContext context, LoginState state) {
          if (state.isFailure) {
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: Text(state.message)),
                      Icon(Icons.error)
                    ],
                  ),
                  backgroundColor: Colors.yellow,
                ),
              );
          }
          if (state.isSubmitting) {
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Logging In...'),
                      CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),),
                    ],
                  ),
                ),
              );
          }
          if (state.isSuccess) {
            BlocProvider.of<AuthenticationBloc>(context).add(LoggedIn());
          }
        },
        child: BlocBuilder(
          bloc: _loginBloc,
          builder: (BuildContext context, LoginState state) {
            return Stack(
              alignment: Alignment.center,
              children: [

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(bottomRight:Radius.circular(200.0),bottomLeft: Radius.circular(200.0,)),
                        gradient: LinearGradient(
                          colors: [
                            Colors.yellow,
                            Colors.black
                          ]
                        )
                      ),
                      child: Image.asset(
                        "assets/auth.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      height: height * 0.09,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: RaisedButton(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          child: Text(
                            "Sign In with Email",
                            style: TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: 15.0,
                                fontWeight: FontWeight.w700),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                SlideTopRoute(
                                  page: LoginScreen(
                                    userRepository: _userRepository,
                                  ),
                                ));
                          },
                          padding: EdgeInsets.all(16.0),
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(

                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,

                                children: <Widget>[


                                  SizedBox(height: isIOS ? 4.0 : 10.0),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height * 0.02,
                          ),




                          Container(
                            height: height * 0.1,
                            child: Center(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>
                                [

                                  SizedBox(
                                    width: 16,
                                  ),
                                  GoogleLoginButton()
                                ],
                              ),
                            ),
                          ),



                        ],
                      ),
                    ),
                    Center(
                      child: Container(
                        height: height * 0.1,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(children: [
                                  TextSpan(
                                      text:
                                      "   By signing up Please read our Privacy Policy and T&C",
                                      style: TextStyle(
                                        fontSize: 9,
                                          color: Colors.black,
                                          fontFamily: "Montserrat")),

                                ]),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Text("College Space",
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),

              ],
            );
          },
        ),
      ),
    );
  }
}
