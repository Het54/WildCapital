import 'package:flutter/material.dart';
import 'package:wildcapital/Watchlist/watchlist_screen.dart';
import 'package:wildcapital/position/position_screen.dart';

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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'WatchLsit',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.bookmark),
          //   label: 'Orders',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Positions',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
       body: <Widget>[
        watchlist_screen(enctoken: enctoken),
        // order_screen(identifier: "home_screen", enctoken: enctoken, triggerPrice: 0.0, tradingsymbol: "Null",targetPrice: 0.00,stoplossPrice: 0.00,quantity: 0,productType: Null, exchange: Null, posType: "",),
        position_screen(enctoken: enctoken),
      ][_selectedIndex],
      
    );
  }
}
