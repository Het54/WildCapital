import 'package:flutter/material.dart';


class Etoken extends StatefulWidget {  
  
const Etoken({ Key? key }) : super(key: key);

  @override
  EtokenState createState() => EtokenState();


}

class EtokenState extends State<Etoken> {

  TextEditingController textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }



  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              Text('WildCapital'),
            ],
          ),
        ),
    body: const Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text("Hello World!"),
      ],
    ), 
  );
}

  
  
}
