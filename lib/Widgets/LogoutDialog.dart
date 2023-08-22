import 'package:flutter/material.dart';
import '../Services/AuthenticationService.dart';

class LogoutDialog extends StatelessWidget {
  // final String title;
  // final String content;
  final AuthService authService;

  LogoutDialog({required this.authService});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20.0), // Juster værdien efter dit ønske.
      ),
      title: Text('Log ud'),
      content: Text('Er du sikker på du vil logge ud af applikationen?'),
      actions: <Widget>[
        TextButton(
          child: Text('Nej'),
          onPressed: () {
            //  _formKey.currentState?.reset();
            Navigator.of(context).pop(); // Luk dialogen.
          },
        ),
        TextButton(
          child: Text('Ja'),
          onPressed: () {
            // Navigator.of(context).pop(); // Luk dialogen.
            authService.Logout();
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    );
  }
}