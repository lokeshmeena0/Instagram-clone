import 'package:flutter/material.dart';

class MyCustomTextFormField extends StatefulWidget {
  final TextEditingController? controller; 
  final String placeholder;
  final keyboardType;
  final bool obscureText;
  final onChanged;
  final validator;

  const MyCustomTextFormField({
    Key? key,
    this.controller,
    required this.placeholder,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  _MyCustomTextFromFieldState createState() => _MyCustomTextFromFieldState();
}

class _MyCustomTextFromFieldState extends State<MyCustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextFormField(
        controller: widget.controller,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        onChanged: widget.onChanged,
        cursorColor: Colors.white,
        cursorWidth: 0.5,
        cursorHeight: 20,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[900],
          hintText: widget.placeholder,
          contentPadding: EdgeInsets.symmetric(horizontal: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
        ),
      ),
    );
  }
}
