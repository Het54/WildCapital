import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> getEnctoken(String userid, String password, String twofa) async {
  var session = http.Client();
  var loginResponse = await session.post(
    Uri.parse('https://kite.zerodha.com/api/login'),
    body: {
      'user_id': userid,
      'password': password,
    },
  );

  var loginData = json.decode(loginResponse.body);
  var twofaResponse = await session.post(
    Uri.parse('https://kite.zerodha.com/api/twofa'),
    body: {
      'request_id': loginData['data']['request_id'],
      'twofa_value': twofa,
      'user_id': loginData['data']['user_id'],
    },
  );

  var enctoken = twofaResponse.headers['set-cookie'];

  if (enctoken != null) {
    return enctoken.split(';')[0].substring('enctoken='.length);
  } else {
    throw Exception("Enter valid details !!!!");
  }
}

class kiteconnect {
  // Products
  static const String PRODUCT_MIS = "MIS";
  static const String PRODUCT_CNC = "CNC";
  static const String PRODUCT_NRML = "NRML";
  static const String PRODUCT_CO = "CO";

  // Order types
  static const String ORDER_TYPE_MARKET = "MARKET";
  static const String ORDER_TYPE_LIMIT = "LIMIT";
  static const String ORDER_TYPE_SLM = "SL-M";
  static const String ORDER_TYPE_SL = "SL";

  // Varieties
  static const String VARIETY_REGULAR = "regular";
  static const String VARIETY_CO = "co";
  static const String VARIETY_AMO = "amo";

  // Transaction type
  static const String TRANSACTION_TYPE_BUY = "BUY";
  static const String TRANSACTION_TYPE_SELL = "SELL";

  // Validity
  static const String VALIDITY_DAY = "DAY";
  static const String VALIDITY_IOC = "IOC";

  // Exchanges
  static const String EXCHANGE_NSE = "NSE";
  static const String EXCHANGE_BSE = "BSE";
  static const String EXCHANGE_NFO = "NFO";
  static const String EXCHANGE_CDS = "CDS";
  static const String EXCHANGE_BFO = "BFO";
  static const String EXCHANGE_MCX = "MCX";

  late Map<String, String> headers;
  late http.Client session;
  late String rootUrl;

  kiteconnect(String enctoken) {
    headers = {"Authorization": "enctoken $enctoken"};
    session = http.Client();
    rootUrl = "https://api.kite.trade";
    // rootUrl = "https://kite.zerodha.com/oms";
    session.get(Uri.parse(rootUrl), headers: headers);
  }

  Future<bool> check_connection() async {
    var response = await session.get(Uri.parse('$rootUrl/portfolio/positions'),
        headers: headers);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> instruments(String s,
      {String? exchange}) async {
    var response =
        await session.get(Uri.parse('$rootUrl/instruments'), headers: headers);
    var data = response.body.split('\n');
    List<Map<String, dynamic>> exchangeList = [];

    for (var i = 1; i < data.length - 1; i++) {
      var row = data[i].split(',');
      if (exchange == null || exchange == row[11]) {
        exchangeList.add({
          'instrument_token': int.tryParse(row[0]) ?? 0,
          'exchange_token': row[1],
          'tradingsymbol': row[2],
          'name': row[3].replaceAll('"', ''),
          'last_price': double.tryParse(row[4]) ?? 0.0,
          'expiry': row[5].isNotEmpty ? DateTime.parse(row[5]).toLocal() : null,
          'strike': double.tryParse(row[6]) ?? 0.0,
          'tick_size': double.tryParse(row[7]) ?? 0.0,
          'lot_size': int.tryParse(row[8]) ?? 0,
          'instrument_type': row[9],
          'segment': row[10],
          'exchange': row[11],
        });
      }
    }

    return exchangeList;
  }

  Future<Map<String, dynamic>> positions() async {
    var response = await session.get(Uri.parse('$rootUrl/portfolio/positions'),
        headers: headers);

    if (response.statusCode == 200) {
      // Check if the response status code is OK (200)
      var positions = json.decode(response.body);
      return positions;
    } else {
      throw Exception('Failed to load positions');
    }
  }

  Future<Map<String, dynamic>> ltp(String instruments) async {
    var response = await session
        .get(Uri.parse('$rootUrl/quote/ltp?i=$instruments'), headers: headers);
    var data = json.decode(response.body)["data"];
    return data;
  }

  Future<Map<String, dynamic>> quote(String instruments) async {
    var response = await session.get(Uri.parse('$rootUrl/quote?i=$instruments'),
        headers: headers);
    var data = json.decode(response.body)["data"];
    return data;
  }

  Future<String?> placeOrder(
      String variety,
      String exchange,
      String tradingsymbol,
      String transactionType,
      int quantity,
      String product,
      String orderType,
      double? price,
      String? validity,
      int? disclosedQuantity,
      double? triggerPrice,
      double? squareoff,
      double? stoploss,
      double? trailingStoploss,
      String? tag) async {
    Map<String, dynamic> params = {
      'variety': variety,
      'exchange': exchange,
      'tradingsymbol': tradingsymbol,
      'transaction_type': transactionType,
      'quantity': quantity.toString(),
      'product': product,
      'order_type': orderType,
      if (price != null) 'price': price.toString(),
      if (validity != null) 'validity': validity,
      if (disclosedQuantity != null)
        'disclosed_quantity': disclosedQuantity.toString(),
      if (triggerPrice != null) 'trigger_price': triggerPrice.toString(),
      if (squareoff != null) 'squareoff': squareoff.toString(),
      if (stoploss != null) 'stoploss': stoploss.toString(),
      if (trailingStoploss != null)
        'trailing_stoploss': trailingStoploss.toString(),
      if (tag != null) 'tag': tag,
    };

    params.removeWhere((key, value) => value == null);

    // print(params);

    final response = await http.post(
      Uri.parse('${rootUrl}/orders/$variety'),
      body: params,
      headers: headers,
    );
    // print(response);
    final data = jsonDecode(response.body);
    // print(data);
    return data['data']['order_id'];
  }
}
