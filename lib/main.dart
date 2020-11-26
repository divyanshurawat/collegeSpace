import 'package:flutter/cupertino.dart';
import 'package:flutterfire/authentication_bloc/authentication_bloc.dart';
import 'package:flutterfire/authentication_bloc/bloc.dart';
import 'package:flutterfire/bloc_delegate.dart';
import 'package:flutterfire/screens/admin/adminPage.dart';
import 'package:flutterfire/screens/auth.dart';
import 'package:flutterfire/screens/home.dart';
import 'package:flutterfire/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutterfire/utils/constants.dart';

import 'login/bloc/bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  BlocSupervisor.delegate = AppBlocDelegate();
  final UserRepository userRepository = UserRepository();
  runApp(BlocProvider(
    create: (context) =>
        AuthenticationBloc(userRepository: userRepository)..add(AppStarted()),
    child: App(userRepository: userRepository),
  ));
}



class App extends StatefulWidget {
  final UserRepository _userRepository;
  const App({
    Key key,
    @required UserRepository userRepository,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);
  @override
  State<StatefulWidget> createState() {
    return AppState();
  }
}

class AppState extends State<App> {
  bool isDark = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDark ? Constants.darkPrimary : Constants.lightPrimary,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Constants.appName,
      theme: isDark ? Constants.darkTheme : Constants.lightTheme,
      home: BlocBuilder(
        bloc: BlocProvider.of<AuthenticationBloc>(context),
        builder: (BuildContext context, AuthenticationState state) {
          if (state is Uninitialized) {
            double height = MediaQuery.of(context).size.height;
            return Scaffold(
              backgroundColor: Colors.yellow,
                  body: SafeArea(
                    child: Stack(
                      children: [



                        Center(child: Text("College Space",style: TextStyle(fontSize: 25,color: Colors.white,fontFamily: "Montserrat"),))
                      ],

                    ),
                  ),
            );

          }
          if (state is Unauthenticated) {
            return BlocProvider<LoginBloc>(
                create: (context) =>
                    LoginBloc(userRepository: widget._userRepository),
                child: AuthScreen(userRepository: widget._userRepository));
          }
          if (state is Authenticated) {


            return Home(user: state.user,);
          }
          return Container();
        },
      ),
    );
  }
}
