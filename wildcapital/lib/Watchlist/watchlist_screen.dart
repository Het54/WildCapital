import 'package:flutter/material.dart';

class watchlist_screen extends StatefulWidget {
  const watchlist_screen({Key? key, required this.enctoken}) : super(key: key);
  final String enctoken;

  @override
  watchlist_screenState createState() => watchlist_screenState();
}

class watchlist_screenState extends State<watchlist_screen> {
  late String enctoken;
  




  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(children: [Text("Hello World!")],),
      ),
    );
  }
}

