import 'package:flutter/material.dart';
import 'package:wildcapital/Orders/order_screen.dart';
import 'package:wildcapital/kiteconnect.dart';
import 'package:intl/intl.dart';

class watchlist_screen extends StatefulWidget {
  const watchlist_screen({Key? key, required this.enctoken}) : super(key: key);
  final String enctoken;

  @override
  watchlist_screenState createState() => watchlist_screenState();
}

class watchlist_screenState extends State<watchlist_screen> {
  late String enctoken;
  List<Map<String, dynamic>> allInstruments = [];
  List<Map<String, dynamic>> filteredInstruments = [];
  String orderType = 'MIS';
  String posType = "Buy";
  TextEditingController triggerPriceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  bool isDisposed = false;

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    enctoken = widget.enctoken;
    get_instruments();
  }

  Future<void> get_instruments() async {
    var kite = kiteconnect(enctoken);
    var instruments = await kite.instruments("NFO");
    // List<Map<String, dynamic>> result = await instruments.where((i) =>
    //     i['name'] == "NIFTY" &&
    //     i['expiry'] == DateTime(2024, 2, 29) &&
    //     i['strike'] == 22050 &&
    //     i['instrument_type'] == "PE").toList();
    // print(result);
    if (!isDisposed) {
      setState(() {
        allInstruments = instruments;
        filteredInstruments = instruments;
      });
    }
  }

  String formatInstrument(Map<String, dynamic> instrument) {
    var expiry = instrument['expiry'];
    if (expiry is DateTime) {
      // 'expiry' is already a DateTime, no need to parse
      return "${instrument['name']} ${DateFormat('dd MMM').format(expiry)} ${instrument['strike']} ${instrument['instrument_type']}";
    } else if (expiry is String) {
      // 'expiry' is a String, parse it to DateTime
      DateTime expiryDateTime = DateTime.parse(expiry);
      return "${instrument['name']} ${DateFormat('dd MMM').format(expiryDateTime)} ${instrument['strike']} ${instrument['instrument_type']}";
    } else {
      // Handle other cases or return a default value
      return "Invalid instrument data";
    }
  }

  void filterInstruments(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredInstruments = allInstruments;
      });
    } else {
      setState(() {
        filteredInstruments = allInstruments
            .where((i) =>
                formatInstrument(i).toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                  'ios/Runner/Assets.xcassets/AppIcon.appiconset/50.png'),
              const Text('KiteFlux'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                onChanged: (query) {
                  filterInstruments(query);
                },
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredInstruments.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, dynamic> instrument =
                        filteredInstruments[index];

                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                      child: ListTile(
                        title: Text(
                          formatInstrument(instrument),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Last Price: ${instrument['last_price']}',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(
                                  "Trigger Price based on ${instrument['name']}",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        18, // Increased font size for title
                                  ),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start, // Align content to left
                                  children: [
                                    Text(
                                      "Position Type:",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    DropdownButtonFormField<String>(
                                      value: posType,
                                      onChanged: (String? value) {
                                        setState(() {
                                          posType = value!;
                                        });
                                      },
                                      items: ['Buy', 'Sell']
                                          .map<DropdownMenuItem<String>>(
                                        (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                    SizedBox(
                                        height:
                                            12.0), // Increased spacing for better readability
                                    Text(
                                      "Order Type:",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    DropdownButtonFormField<String>(
                                      value: orderType,
                                      onChanged: (String? value) {
                                        setState(() {
                                          orderType = value!;
                                        });
                                      },
                                      items: ['MIS', 'NRML']
                                          .map<DropdownMenuItem<String>>(
                                        (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                    SizedBox(
                                        height:
                                            12.0), // Increased spacing for better readability
                                    TextFormField(
                                      controller: triggerPriceController,
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      decoration: InputDecoration(
                                        hintText: 'Enter trigger price',
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            12.0), // Increased spacing for better readability
                                    TextFormField(
                                      controller: quantityController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'Enter Quantity',
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
                                      // Validate trigger price and send it to another screen
                                      String triggerPriceText =
                                          triggerPriceController.text.trim();
                                      if (triggerPriceText.isNotEmpty) {
                                        // Convert the trigger price to a float
                                        double triggerPrice =
                                            double.tryParse(triggerPriceText) ??
                                                0.0;

                                        // Send triggerPrice to another screen
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => order_screen(
                                              identifier: "watchlist_screen",
                                              enctoken: widget.enctoken,
                                              triggerPrice: triggerPrice,
                                              tradingsymbol:
                                                  instrument['tradingsymbol'],
                                              posType: posType,
                                              targetPrice: 0.00,
                                              stoplossPrice: 0.00,
                                              quantity: int.parse(
                                                  quantityController.text),
                                              productType: orderType,
                                              exchange: Null,
                                            ),
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
            ],
          ),
        ),
      ),
    );
  }
}
