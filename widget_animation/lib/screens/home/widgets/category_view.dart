import 'package:flutter/material.dart';

class CategoryView extends StatefulWidget {
  @override
  _CategoryViewState createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {

  final List<String> categories = [
    "Trabalho",
    "Estudos",
    "Casa"
  ];

  int _category = 0;

  void selectFoward(){
    setState(() {
      _category++;
    });
  }

  void selectbackward(){
    setState(() {
      _category--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
          disabledColor: Colors.white30,
          onPressed: _category > 0 ? selectbackward : null,
        ),
        Text(
          categories[_category],
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w500
          ),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward_ios),
          color: Colors.white,
          disabledColor: Colors.white30,
          onPressed: _category < categories.length -1 ? selectFoward : null,
        ),
      ],
    );
  }
}
