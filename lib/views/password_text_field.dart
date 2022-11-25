import 'package:flutter/material.dart';
import 'package:note_bloc_app/strings.dart' show enterYourPasswordHere;

class PasswordTextField extends StatelessWidget {
  final TextEditingController passwordController;

  const PasswordTextField({
    Key? key,
    required this.passwordController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: passwordController,
      obscureText: true,
      obscuringCharacter: '●',
      autocorrect: false,
      decoration: const InputDecoration(hintText: enterYourPasswordHere),
    );
  }
}
