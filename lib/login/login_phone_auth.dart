import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire/authentication_bloc/bloc.dart';
import 'package:flutterfire/login/login.dart';
import 'package:flutterfire/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';

class PhoneAuth extends StatefulWidget {
  final UserRepository _userRepository;

  PhoneAuth({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  State<PhoneAuth> createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  int _otpCodeLength = 6;
  bool _isLoadingButton = false;
  bool _enableButton = false;
  String _otpCode = "";
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  LoginBloc _loginBloc;

  bool isCodeSent = false;
  String _verificationId;

  UserRepository get _userRepository => widget._userRepository;

  bool get isPopulated => _phoneNumberController.text.isNotEmpty;

  bool isLoginButtonEnabled(LoginState state) {
    return state.isPhoneValid && isPopulated && !state.isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    _phoneNumberController.addListener(_onPhoneChanged);
    _getSignatureCode();
  }
  /// get signature code
  _getSignatureCode() async {
    String signature = await SmsRetrieved.getAppSignature();
    print("signature $signature");
  }
  _onOtpCallBack(String otpCode, bool isAutofill) {
    setState(() {
      this._otpCode = otpCode;
      if (otpCode.length == _otpCodeLength && isAutofill) {
        _enableButton = false;
        _isLoadingButton = true;
        _onVerifyCode();
        //_verifyOtpCode();
      } else if (otpCode.length == _otpCodeLength && !isAutofill) {
        _enableButton = true;
        _isLoadingButton = false;
      } else {
        _enableButton = false;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _loginBloc,
      listener: (BuildContext context, LoginState state) {
        if (state.isFailure) {
          setState(() {
            isCodeSent = false;
          });
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
                backgroundColor: Colors.red,
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
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }
        if (state.isSuccess) {
          Navigator.pop(context);
          BlocProvider.of<AuthenticationBloc>(context).add(LoggedIn());
        }
      },
      child: BlocBuilder(
        bloc: _loginBloc,
        builder: (BuildContext context, LoginState state) {
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
            backgroundColor: Colors.white,
            body: Padding(
              padding: EdgeInsets.all(20.0),
              child: Form(
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      child: Text(
                        "Login with Phone",
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Montserat",
                            fontWeight: FontWeight.bold,
                            fontSize: 32.0),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: TextFormField(
                        controller: _phoneNumberController,


                        enableSuggestions: false,
                        autofocus: true,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Phone",

                          suffix: _phoneNumberController.text == "" ||
                                  _phoneNumberController.text == null
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
                                    _phoneNumberController.text = "";
                                  },
                                ),
                        ),
                        autovalidate: true,
                        autocorrect: false,
                        validator: (value) {
                          return !state.isPhoneValid
                              ? 'Invalid Phone Number'
                              : null;
                        },
                      ),
                    ),
                    isCodeSent
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            child:  TextFieldPin(

                              filled: true,
                              filledColor: Colors.grey[400],
                              codeLength: _otpCodeLength,
                              boxSize: 46,
                              filledAfterTextChange: false,
                              textStyle: TextStyle(fontSize: 16),
                              borderStyle: OutlineInputBorder(

                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(34)),
                              onOtpCallback: (code, isAutofill) =>
                                  _onOtpCallBack(code, isAutofill),
                            ),
                          )
                        : Container()
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              elevation: 0.0,
              child: isCodeSent&&_isLoadingButton ?CircularProgressIndicator() : Icon(Icons.arrow_forward_ios),
              foregroundColor: Colors.white,
              backgroundColor: isLoginButtonEnabled(state)
                  ? Theme.of(context).primaryColor
                  : Colors.grey[400],
              onPressed: isLoginButtonEnabled(state)
                  ? !isCodeSent ? _onVerifyCode : _onFormSubmitted
                  : null,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    _loginBloc.add(
      PhoneChanged(phone: _phoneNumberController.text),
    );
  }

  void _onVerifyCode() async {
    print("verify called");

    setState(() {
      _isLoadingButton = !_isLoadingButton;
      isCodeSent = true;
    });

    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _firebaseAuth.signInWithCredential(phoneAuthCredential);
    };
    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      Scaffold.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(authException.message)),
                Icon(Icons.error)
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      FocusScope.of(context).requestFocus(new FocusNode());
      Timer(Duration(milliseconds: 5000), () {
        setState(() {
          _isLoadingButton = false;
          _enableButton = false;
          isCodeSent = false;
        });

      });

    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      _verificationId = verificationId;
      setState(() {
        _verificationId = verificationId;
      });
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
      setState(() {
        _verificationId = verificationId;
      });
    };

    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: _phoneNumberController.text,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _onFormSubmitted() {
    print(_verificationId);
    _loginBloc.add(
      LoginWithPhonePressed(
          smsCode: _smsCodeController.text, verificationCode: _verificationId),
    );
  }
}
