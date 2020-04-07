import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _currencies;
  final List<MaterialColor> _colors = [Colors.blue, Colors.indigo, Colors.red];

  final formatCurrency = new NumberFormat.simpleCurrency();
  var formatNumber = NumberFormat('###.0#', 'en_US');

  @override
  void initState() {
    _getCurrencies().then((returnedCurrencies) {
      setState(() {
        _currencies = returnedCurrencies;
      });
    });
    super.initState();
  }

  Future<List> _getCurrencies() async {
    String url =
        "https://sandbox-api.coinmarketcap.com/v1/cryptocurrency/listings/latest";
    http.Response response = await http.get(url,
        headers: {"X-CMC_PRO_API_KEY": "51420a53-2b39-4949-87ce-36015a4e8289"});
    Map json = jsonDecode(response.body);
    return json["data"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
          title: Text("Krypto App"),
        ),
        body: _cryptoWidget());
  }

  Widget _cryptoWidget() {
    return Column(
      children: <Widget>[
        Flexible(
            child: ListView.builder(
          itemCount: _currencies == null ? 0 : _currencies.length,
          itemBuilder: (context, index) {
            final Map currency = _currencies[index];
            final MaterialColor color = _colors[index % _colors.length];
            return _renderListItemUI(currency, color);
          },
        ))
      ],
    );
  }

  ListTile _renderListItemUI(Map currency, MaterialColor color) {
    return ListTile(
      leading: CircleAvatar(
          backgroundColor: color,
          child:
              Text(currency['name'][0], style: TextStyle(color: Colors.white))),
      title:
          Text(currency['name'], style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: _renderSubtitleText(
        currency['quote']['USD']['price'],
        currency['quote']['USD']['percent_change_1h'],
      ),
    );
  }

  Widget _renderSubtitleText(double priceUSD, double percentageChange) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text("${formatCurrency.format(priceUSD)}",
            style: TextStyle(color: Colors.black)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("${formatNumber.format(percentageChange)}%",
                style: TextStyle(
                    color: percentageChange > 0 ? Colors.green : Colors.red)),
            SizedBox(width: 5),
            Icon(
                percentageChange > 0
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: percentageChange > 0 ? Colors.green : Colors.red,
                size: 15),
          ],
        )
      ],
    );
  }
}
