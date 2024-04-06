import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wildcapital/Orders/order_screen.dart';
import 'package:wildcapital/kiteconnect.dart';

class position_screen extends StatefulWidget {
  const position_screen({Key? key, required this.enctoken}) : super(key: key);

  final String enctoken;

  @override
  position_screenState createState() => position_screenState();
}

class position_screenState extends State<position_screen> {
  late String enctoken;
  List<dynamic> PositionList = [];
  late Timer timer;
  dynamic toatlpnl = 0;

  bool isDisposed = false;

  @override
  void dispose() {
    timer.cancel();
    isDisposed = true;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    enctoken = widget.enctoken;
    get_position();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      get_last_price(); // Update positions every second
    });
  }

  Future<void> get_position() async {
    try {
      var kite = kiteconnect(enctoken);
      var positions = await kite.positions();
      setState(() {
        PositionList = positions['data']['net'];
        print(PositionList);
      });
    } catch (e) {
      print("Error fetching positions: $e");
      // Handle error
    }
  }

  get_last_price() async {
    for (int i = 0; i < PositionList.length; i++) {
      String exchange = PositionList[i]['exchange'];
      String tradingsymbol = PositionList[i]['tradingsymbol'];
      String result = '$exchange:$tradingsymbol';

      var kite = kiteconnect(enctoken);
      var lastp = await kite.ltp(result);
      var average = PositionList[i]['average_price'];
      var qty = PositionList[i]['quantity'];
      var lastprice = lastp[result]['last_price'];
      var pnl = PositionList[i]['pnl'];
      var op_type = tradingsymbol.substring(tradingsymbol.length - 2);

      //need to create a condition for buy and sell positions seperately
      if (op_type == "PE") {
        if (qty < 0) {
          pnl = (average - lastprice) * -(qty);
        } else if (qty > 0) {
          pnl = (average - lastprice) * -(qty);
        }
      } else if (op_type == "CE") {
        if (qty < 0) {
          pnl = (average - lastprice) * -(qty);
        } else if (qty > 0) {
          pnl = (average - lastprice) * -(qty);
        }
      }

      toatlpnl += pnl;
      if (!isDisposed && qty != 0) {
        setState(() {
          PositionList[i]['last_price'] = lastprice;
          PositionList[i]['pnl'] = pnl;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPnL =
        PositionList.fold(0, (sum, position) => sum + (position['pnl'] ?? 0.0));

    Color totalPnLColor = totalPnL > 0
        ? Colors.green
        : totalPnL < 0
            ? Colors.red
            : Colors.black;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                  'ios/Runner/Assets.xcassets/AppIcon.appiconset/50.png'),
              const Text('wildcapital'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: PositionList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, dynamic> positionList =
                        PositionList[index];

                    // Determine the color based on the quantity
                    Color quantityColor = positionList['quantity'] >= 0
                        ? Colors.green
                        : Colors.red;

                    // Determine the color based on P&L
                    Color pnlColor =
                        positionList['pnl'] >= 0 ? Colors.green : Colors.red;

                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Qty: ${positionList['quantity']}',
                                  style: TextStyle(
                                    color: quantityColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${positionList['exchange']}',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  positionList['tradingsymbol'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'P&L: ',
                                  style: TextStyle(
                                    color: pnlColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${positionList['pnl'].toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: pnlColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Type: ${positionList['product']}',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text('LTP: ${positionList['last_price']}'),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text('Avg: ${positionList['average_price']}'),
                          ],
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              TextEditingController stoplosscontroller =
                                  TextEditingController();
                              TextEditingController targetcontroller =
                                  TextEditingController();

                              return AlertDialog(
                                title: Text(
                                  "Place Stop Loss and Target",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Enter Stoploss Price:",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    TextFormField(
                                      controller: stoplosscontroller,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'Enter Stoploss',
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      "Enter Target Price:",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    TextFormField(
                                      controller: targetcontroller,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'Enter Target',
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      String Stoplosspricetext =
                                          stoplosscontroller.text.trim();
                                      String Targetpricetext =
                                          targetcontroller.text.trim();
                                      if (Stoplosspricetext.isNotEmpty &&
                                          Targetpricetext.isNotEmpty) {
                                        // Convert the trigger price to a float
                                        double stoplossprice = double.tryParse(
                                                Stoplosspricetext) ??
                                            0.0;
                                        double targetprice =
                                            double.tryParse(Targetpricetext) ??
                                                0.0;

                                        // Send triggerPrice to another screen
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => order_screen(
                                                identifier: "position_screen",
                                                enctoken: widget.enctoken,
                                                triggerPrice: 0.00,
                                                tradingsymbol: positionList[
                                                    'tradingsymbol'],
                                                targetPrice: targetprice,
                                                stoplossPrice: stoplossprice,
                                                posType: "",
                                                quantity:
                                                    positionList['quantity'],
                                                productType:
                                                    positionList['product'],
                                                exchange:
                                                    positionList['exchange']),
                                          ),
                                        );
                                      } else {
                                        // Show an error message if trigger price is not entered
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Please enter a valid trigger price.'),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text('Submit'),
                                  ),
                                ],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                backgroundColor: Colors.white,
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(
                    8.0), // Add padding of 8.0 (adjust as needed)
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total P&L',
                      style: TextStyle(
                        fontSize: 18, // Adjust the font size as needed
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${totalPnL.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: totalPnL > 0
                            ? Colors.green
                            : totalPnL < 0
                                ? Colors.red
                                : Colors.black,
                        fontSize: 18, // Adjust the font size as needed
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
