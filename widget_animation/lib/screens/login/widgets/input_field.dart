import 'package:flutter/material.dart';

class InputField extends StatelessWidget {

  final String hint;
  final bool obscure;
  final IconData icon;

  InputField({this.hint, this.obscure, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Colors.white24,
                  width: 0.5
              )
          )
      ),
      child: TextFormField(
        obscureText: obscure,
        style: TextStyle(
            color: Colors.white
        ),
        decoration: InputDecoration(
            icon: Icon(
              icon,
              color: Colors.white,
            ),
            border: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(
                color: Colors.white,
                fontSize: 15.0
            ),
            contentPadding: EdgeInsets.only(
                top: 30.0, right: 30.0, bottom: 30.0, left: 5.0)
        ),
      ),
    );
  }
}
