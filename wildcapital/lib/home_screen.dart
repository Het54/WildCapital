import 'package:flutter/material.dart';

class home_screen extends StatefulWidget {
  const home_screen({super.key, required this.enctoken});
  final String enctoken;

  @override
  State<home_screen> createState() =>
      _home_screenState();
}

class _home_screenState extends State<home_screen> {

  int _selectedIndex = 0;
  late String enctoken;

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    enctoken = widget.enctoken;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [Text("Hello World!")]),
      
    );
  }
}
