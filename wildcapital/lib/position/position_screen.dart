import 'package:flutter/material.dart';


class position_screen extends StatefulWidget {
  const position_screen({Key? key, required this.enctoken}) : super(key: key);

  final String enctoken;

  @override
  position_screenState createState() => position_screenState();
}

class position_screenState extends State<position_screen> {
  late String enctoken;


  

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(children: [Text("Hello world!")],),
      ),
    );
  }

}
