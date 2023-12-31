import 'package:flutter/material.dart';
import 'package:flutter_comfortcare/Model/Employee.dart';
import 'package:http/http.dart';
import '../Widgets/MainPageContent.dart';
import '../Services/AuthenticationService.dart';
import '../Widgets/InternetDialog.dart';
import '../Widgets/WrongUserDialog.dart';

class LoginPage extends StatefulWidget {
  final AuthService authService;

  LoginPage({required this.authService});

  @override
  _LoginPageState createState() =>
      _LoginPageState(authService: this.authService);
}

class _LoginPageState extends State<LoginPage> {
  final AuthService authService;

  _LoginPageState({required this.authService});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _submitFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _formKey.currentState?.reset();
  }

  void handleLogin(BuildContext context) async {
    //disable focus on input fields
    _usernameFocusNode.unfocus();
    _passwordFocusNode.unfocus();

    //check if user has filled out form
    if (_formKey.currentState!.validate()) {
      var response = await authService.login(
          _usernameController.text, _passwordController.text);


      Employee user = Employee(
          name: _usernameController.text, password: _passwordController.text);


      //if successful response check status codes
      if (response != null) {
        //successful login
        if (response.statusCode == 200) {
          // Navigate to the MainPage after successful login
          Navigator.pushReplacementNamed(context, '/mainPage');
        }
        //status 500 data not available
        else if (response.statusCode == 500) {
          String title;
          title = 'Data ikke tilgængelig';

          //check user loging
          //check if user is stored in securestorage
          if (await this.authService.checkUserLogin(user)) {
            //show dialog box if user is saved in securestorage

            //username validated - continuing to dialogbox
            await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return InternetDialog(
                    title: title,
                    onClose: () {
                      _formKey.currentState?.reset();
                    },
                  );
                });
          }
          //user is invalid - showing wrong user dialogbox
          else {
            //show dialog box if user is not stored in securestorage
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return WrongUserDialog(
                  content:
                      'Brugeren eksisterer ikke lokalt, prøv igen senere når data er tilgængelig',
                );
              },
            );
          }
        }
        //status 503 - no internet
        else if (response.statusCode == 503) {
          String title;
          title = 'Ingen internet';

          //check user loging
          //check if user is stored in securestorage
          if (await this.authService.checkUserLogin(user)) {
            //show dialog box if user is saved in securestorage
            //username validated - continuing to dialogbox
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return InternetDialog(
                  title: title,
                  onClose: () {
                    _formKey.currentState?.reset();
                  },
                );
              },
            );
          }
          //user is invalid - showing wrong user dialogbox
          else {
            //show dialog box if user is not stored in securestorage
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return WrongUserDialog(
                  content:
                      'Brugeren eksisterer ikke lokalt, for at få adgang skal du være online',
                );
              },
            );
          }
        }
        //status 400 - user credentials wrong
        else if (response.statusCode == 400) {
          //show dialog box if username and password is wrong
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return WrongUserDialog(
                content: 'Brugernavn eller password er forkert',
              );
            },
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 128,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Image.asset(
            'assets/icon/comfortCareLogo.png',
            width: 128,
            height: 128,
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.25,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      focusNode: _usernameFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) {
                        _fieldFocusChange(
                            context, _usernameFocusNode, _passwordFocusNode);
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        labelText: 'Brugernavn',
                        hintText: 'Brugernavn',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'skriv venligst dit brugernavn';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        handleLogin(context);
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.lock),
                        labelText: 'Kodeord',
                        hintText: 'Kodeord',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'skriv venligst dit password.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      focusNode: _submitFocusNode,
                      onPressed: () => handleLogin(context),
                      icon: Icon(Icons.login),
                      label: Text('Login'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

_fieldFocusChange(
    BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}
