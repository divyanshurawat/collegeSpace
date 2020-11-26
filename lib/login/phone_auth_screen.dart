import 'package:flutterfire/login/login.dart';
import 'package:flutterfire/login/login_phone_auth.dart';
import 'package:flutterfire/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PhoneAuthScreen extends StatelessWidget {
  final UserRepository _userRepository;

  PhoneAuthScreen({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
        create: (context) => LoginBloc(userRepository: _userRepository),
        child: Scaffold(body: PhoneAuth(userRepository: _userRepository)));
  }
}
