import 'dart:async';
import 'dart:math';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:wildcapital/kiteconnect.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;


class order_screen extends StatefulWidget {
  const order_screen({Key? key, required this.identifier, required this.enctoken, required this.triggerPrice, required this.tradingsymbol, required this.targetPrice, required this.stoplossPrice, required this.quantity, required this.productType, required this.exchange, required this.posType}) : super(key: key);

  final String identifier;
  final String enctoken;
  final String posType;
  final double triggerPrice;
  final dynamic tradingsymbol;
  final double targetPrice;
  final double stoplossPrice;
  final int quantity;
  final dynamic productType;
  final dynamic exchange;

  @override
  order_screenState createState() => order_screenState();
}

class order_screenState extends State<order_screen> {
  late String identifier;
  late String enctoken; 
  late String posType;
  late double triggerPrice;
  late dynamic tradingsymbol;
  late double targetPrice;
  late double stoplossPrice;
  late int quantity;
  late dynamic productType;
  late dynamic exchange;
  late String index_name;
  var indexlp;
  late Timer timer;
  List<dynamic> OrderList = [];
  DatabaseReference ref = FirebaseDatabase.instance.ref("users/het");
  Random random = Random();
  



  @override
  void initState() {
    super.initState();
  
    identifier = widget.identifier;
    enctoken = widget.enctoken;
    triggerPrice = widget.triggerPrice;
    tradingsymbol = widget.tradingsymbol;
    targetPrice = widget.targetPrice;
    stoplossPrice = widget.stoplossPrice;
    quantity = widget.quantity;
    productType = widget.productType;
    posType = widget.posType;
    exchange = widget.exchange;
    RegExp regex = RegExp(r'^[a-zA-Z]+');
    Match? match = regex.firstMatch(tradingsymbol);
    index_name = match?.group(0) ?? '';
    if(identifier == "position_screen"){
      OrderList.add(
        {
          "tradingsymbol": tradingsymbol,
          "stoploss": stoplossPrice,
          "target": targetPrice,
          "quantity": quantity,
          "product": productType,
          "exchange": exchange,
        }
      );
      get_last_price_position();
      //Stoe Stop_loss and target price in firebase
    }

    else if(identifier == "watchlist_screen"){
      OrderList.add(
        {
          "tradingsymbol": tradingsymbol,
          "triggerprice": triggerPrice,
          "quantity": quantity,
          "product": productType,
        }
      );
      get_last_price_watchlist();
    }


    
  }

  triggerNotification_for_position(){
    print("inside function");
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1, 
        channelKey: 'basic_channel',
        title: 'Target Hit',
        body: 'Current position is been executed',
        ));
  }

  triggerNotification_for_watchlist(){
    print("inside function");
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1, 
        channelKey: 'basic_channel',
        title: 'Trigger Price Hit',
        body: 'Position is been executed',
        ));
  }



  get_last_price_position() async {
    for(int i=0; i<OrderList.length; i++){
      String result = "";
      if(index_name == "NIFTY"){
        result = 'NSE:NIFTY 50';
      }
      else if(index_name == "BANKNIFTY"){
        result = 'NSE:NIFTY BANK';
      }
      else if(index_name == "FINNIFTY"){
        result = 'NSE:NIFTY FIN SERVICE';
      }
      var kite = kiteconnect(enctoken);

      
      

      String op_type = tradingsymbol.substring(tradingsymbol.length - 2);
      if(productType == "MIS"){
          productType = kiteconnect.PRODUCT_MIS;
      }
      else{
          productType = kiteconnect.PRODUCT_NRML;
      }

      if(quantity>0){ //Buy Position
      
        if(op_type == 'CE'){
          final periodicTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
            // var index_lp = await kite.ltp(result);
            // print(index_lp);
            // indexlp = index_lp[result]['last_price'];

            //For testing purpose
            var request = http.Request('GET', Uri.parse('http://127.0.0.1:5000/data'));


            http.StreamedResponse response = await request.send();
            var string  = await response.stream.bytesToString();
            indexlp = double.parse(string);
            // print(indexlp);
            
            setState(() {
            });
            if(indexlp>=targetPrice || indexlp<=stoplossPrice){
              triggerNotification_for_position();
              // sell_order(tradingsymbol, quantity, productType);
              int randomNumber = random.nextInt(100);
              ref.set({
                "order_id": randomNumber,
                "Position_status": "Target Hit",
              });
              timer.cancel();
            }              
            },
          );
        }

        else if(op_type == 'PE'){
          final periodicTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
            var index_lp = await kite.ltp(result);
            indexlp = index_lp[result]['last_price'];
            setState(() {
            });
            if(indexlp<=targetPrice || indexlp>=stoplossPrice){
              sell_order(tradingsymbol, quantity, productType);
              timer.cancel();
            }              
          },
          );
        }
      }

      else if(quantity<0){ //Sell Position

        if(op_type == 'CE'){
          final periodicTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
            var index_lp = await kite.ltp(result);
            indexlp = index_lp[result]['last_price'];
            setState(() {
            });
            if(indexlp<=targetPrice || indexlp>=stoplossPrice){
              buy_order(tradingsymbol, quantity, productType);
              timer.cancel();
              if(indexlp>=targetPrice){
                //store Target price hit in firebase
              }
              else{
                //store Stopp loss price hit in firebase
              }
            }              
          },
          );
        }

        else if(op_type == 'PE'){
          final periodicTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
            var index_lp = await kite.ltp(result);
            indexlp = index_lp[result]['last_price'];
            setState(() {
            });
            if(indexlp>=targetPrice || indexlp<=stoplossPrice){
              sell_order(tradingsymbol, quantity, productType);
              timer.cancel();
            }              
          },
          );
        }
      }
    }
    
    
  }



  get_last_price_watchlist() async {
    for(int i=0; i<OrderList.length; i++){
      String result = "";
      if(index_name == "NIFTY"){
        result = 'NSE:NIFTY 50';
      }
      else if(index_name == "BANKNIFTY"){
        result = 'NSE:NIFTY BANK';
      }
      else if(index_name == "FINNIFTY"){
        result = 'NSE:NIFTY FIN SERVICE';
      }
      var kite = kiteconnect(enctoken);
      var index_lp = await kite.ltp(result);

      String op_type = tradingsymbol.substring(tradingsymbol.length - 2);
      if(productType == "MIS"){
          productType = kiteconnect.PRODUCT_MIS;
      }
      else{
          productType = kiteconnect.PRODUCT_NRML;
      }
      
      if(op_type == 'CE'){
        if(posType == 'Buy'){
            Timer.periodic(const Duration(milliseconds: 500), (timer) async {
            // var index_lp = await kite.ltp(result);
            // indexlp = index_lp[result]['last_price'];

            //For testing purpose
            var request = http.Request('GET', Uri.parse('http://127.0.0.1:5000/data'));


            http.StreamedResponse response = await request.send();
            var string  = await response.stream.bytesToString();
            indexlp = double.parse(string);


            setState(() {
            });
            if(indexlp>triggerPrice){
              // buy_order(tradingsymbol, quantity, productType);
              triggerNotification_for_watchlist();
              timer.cancel();
            }              
            },
          );
        }

        else if(posType == 'Sell'){
            Timer.periodic(const Duration(milliseconds: 500), (timer) async {
            var index_lp = await kite.ltp(result);
            indexlp = index_lp[result]['last_price'];
            setState(() {
            });
            if(indexlp<triggerPrice){
              sell_order(tradingsymbol, quantity, productType);
              timer.cancel();
            }              
            },
          );
        }
        
      }

      else if(op_type == 'PE'){
        if(posType == 'Buy'){
            Timer.periodic(const Duration(milliseconds: 500), (timer) async {
            var index_lp = await kite.ltp(result);
            indexlp = index_lp[result]['last_price'];
            setState(() {
            });
            if(indexlp<triggerPrice){
              buy_order(tradingsymbol, quantity, productType);
              timer.cancel();
            }              
            },
          );
        }

        else if(posType == 'Sell'){
            Timer.periodic(const Duration(milliseconds: 500), (timer) async {
            var index_lp = await kite.ltp(result);
            indexlp = index_lp[result]['last_price'];
            setState(() {
            });
            if(indexlp>triggerPrice){
              sell_order(tradingsymbol, quantity, productType);
              timer.cancel();
            }              
            },
          );
        }
      }

    }
    
    
  }


  sell_order(t_symbol, quantity, product_type) async{
    var kite = kiteconnect(enctoken);
    kite.placeOrder(kiteconnect.VARIETY_REGULAR, kiteconnect.EXCHANGE_NFO, t_symbol, kiteconnect.TRANSACTION_TYPE_SELL, quantity, product_type, kiteconnect.ORDER_TYPE_MARKET, null, null,null,null,null,null,null,"Sell_oreder");
  }

  buy_order(t_symbol, quantity, product_type) async{
    var kite = kiteconnect(enctoken);
    kite.placeOrder(kiteconnect.VARIETY_REGULAR, kiteconnect.EXCHANGE_NFO, t_symbol, kiteconnect.TRANSACTION_TYPE_BUY, quantity, product_type, kiteconnect.ORDER_TYPE_MARKET, null, null,null,null,null,null,null,"Buy_oreder");
  }

  

  

  @override
  Widget build(BuildContext context) {
    var text = "Stop Service";
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              Image.asset('ios/Runner/Assets.xcassets/AppIcon.appiconset/50.png'), 
              const Text('KiteFlux'),
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
                  itemCount: OrderList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, dynamic> orderList =
                        OrderList[index];

                    // Determine the color based on the quantity
                    Color quantityColor =
                        orderList['quantity'] >= 0 ? Colors.green : Colors.red;
                    
                    Color posTypeColor = 
                        posType == 'Buy' ? Colors.green : Colors.red;

                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(
                          vertical: 3, horizontal: 3),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Qty: ${orderList['quantity']}',
                                  style: TextStyle(
                                    color: quantityColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Type: ${orderList['product']}',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            SizedBox(height: 5), 
                            Text(
                                  orderList['tradingsymbol'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: identifier == "watchlist_screen" ? [
                                Text(
                                  'Trigger Price: $triggerPrice',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'PosType: $posType',
                                  style: TextStyle(color: posTypeColor),
                                ),
                              ] : identifier == "position_screen" ? [
                                Text(
                                  'SL: ${orderList['stoploss']}',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Tgt: ${orderList['target']}',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ] : [], // Empty array as a fallback if identifier doesn't match any condition
                            ),
                            SizedBox(height: 5),


                            Text(
                                  '$index_name: $indexlp',
                                  style: TextStyle(color: Colors.green),
                                ),
                          ],
                        ),
                        onTap: () {
                          // handle ontap here
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