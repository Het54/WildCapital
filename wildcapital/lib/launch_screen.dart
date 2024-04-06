import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wildcapital/etoken_screen.dart';

class launch_screen extends StatefulWidget {
  const launch_screen({Key? key}) : super(key: key);

  @override
  launch_screenState createState() => launch_screenState();
}

class launch_screenState extends State<launch_screen> {


  @override
  void initState() {
    super.initState();
    // Navigate to next screen after 5 seconds
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Etoken()),
      );
    });
  }



  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  'WildCapital',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

}
