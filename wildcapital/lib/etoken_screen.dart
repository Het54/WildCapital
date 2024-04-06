import 'package:flutter/material.dart';
import 'package:kiteflux/Position/position_screen.dart';
import 'package:kiteflux/home_screen.dart';
import 'package:kiteflux/kiteconnect.dart';

class Etoken extends StatefulWidget {
  const Etoken({Key? key}) : super(key: key);

  @override
  EtokenState createState() => EtokenState();
}

class EtokenState extends State<Etoken> {
  TextEditingController textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  connectwithkite(String enctoken) async {
    kiteconnect(enctoken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('ios/Runner/Assets.xcassets/AppIcon.appiconset/50.png'),
            const Text('KiteFlux'),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 250,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextField(
              controller: textFieldController,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal)),
                enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(247, 255, 104, 104))),
                border: OutlineInputBorder(),
                labelText: 'EncToken',
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shadowColor: Colors.teal,
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0)),
            ),
            onPressed: () async {
              if (await kiteconnect(textFieldController.text)
                      .check_connection() ==
                  true) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        home_screen(enctoken: textFieldController.text),
                  ),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        "Error",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        "Invalid Enc Token!",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      backgroundColor: Colors.white,
                    );
                  },
                );
              }
            },
            child: const Text('Submit',
                style: TextStyle(color: Colors.teal, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}



// List y = await connectwithkite(textFieldController.text);
//             String z = y.toString();
//             showDialog(
//             context: context,
//             builder: (context) {
//               return AlertDialog(
//                 // Retrieve the text the that user has entered by using the
//                 // TextEditingController.
//                 content: Text(z),
//               );
//             },
//           );


// var positions = await kite.positions();
    // await Future.delayed(Duration(seconds: 2));
    // print(positions);
    // var x = positions['data']["day"][1]['tradingsymbol'];
    // return (x);
    // var instruments = await kite.instruments("NFO");
    // print(instruments);
