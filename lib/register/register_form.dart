import 'package:flutterfire/authentication_bloc/bloc.dart';
import 'package:flutterfire/register/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterfire/repositories/user_repository.dart';

class RegisterScreen extends StatelessWidget {
  final UserRepository _userRepository;
  final String email;
  final String birthday;
  final String name;
  RegisterScreen(
      {Key key,
      @required UserRepository userRepository,
      @required this.email,
      @required this.birthday,
      @required this.name})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterBloc>(
        create: (context) => RegisterBloc(userRepository: _userRepository),
        child: Scaffold(
          body: RegisterForm(
            email: email,
            name: name,
            birthday: birthday,
          ),
        ));
  }
}

class RegisterForm extends StatefulWidget {
  RegisterForm(
      {@required this.email, @required this.name, @required this.birthday})
      : super();
  final String email, name, birthday;

  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _passwordController = TextEditingController();

  RegisterBloc _registerBloc;

  bool get isPopulated => _passwordController.text.isNotEmpty;

  bool isRegisterButtonEnabled(RegisterState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    _registerBloc = BlocProvider.of<RegisterBloc>(context);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _registerBloc,
      listener: (BuildContext context, RegisterState state) {
        if (state.isSubmitting) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Registering...'),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }
        if (state.isSuccess) {
          BlocProvider.of<AuthenticationBloc>(context).add(LoggedIn());
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
        if (state.isFailure) {
          print(state.message);
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text(state.message)),
                    Icon(Icons.error),
                  ],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }
      },
      child: BlocBuilder(
        bloc: _registerBloc,
        builder: (BuildContext context, RegisterState state) {
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
                child: Form(
                    child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      child: Text(
                        "Enter a new password",
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Montserat",
                            fontWeight: FontWeight.bold,
                            fontSize: 32.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        autofocus: true,
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffix: _passwordController.text == "" ||
                                  _passwordController.text == null
                              ? Container(
                                  height: 0.0,
                                  width: 0.0,
                                )
                              : GestureDetector(
                                  child: Icon(
                                    Icons.close,
                                    size: 16.0,
                                  ),
                                  onTap: () {
                                    _passwordController.text = "";
                                  },
                                ),
                        ),
                        obscureText: true,
                        autocorrect: false,
                        autovalidate: true,
                        validator: (value) {
                          return value.length > 3 && !state.isPasswordValid
                              ? 'Invalid Password'
                              : null;
                        },
                      ),
                    ),
                  ],
                )),
              ),
              floatingActionButton: FloatingActionButton(
                elevation: 0.0,
                child: Icon(Icons.check),
                foregroundColor: Colors.white,
                backgroundColor: state.isPasswordValid
                    ? Theme.of(context).primaryColor
                    : Colors.grey[400],
                onPressed: state.isPasswordValid ? _onFormSubmitted : null,
              ),
              backgroundColor: Colors.white);
        },
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    _registerBloc.add(
      PasswordChanged(password: _passwordController.text),
    );
  }

  // add with birthday field.

  void _onFormSubmitted() {
    _registerBloc.add(
      Submitted(

        name: widget.name,
        birthday: widget.birthday,
        email: widget.email,
        password: _passwordController.text,
      ),
    );
  }
}
