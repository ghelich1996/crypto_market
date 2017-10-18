import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:crypto_market/models.dart';
import 'package:http/http.dart' as http;

class ForecastPage extends StatefulWidget {

  ForecastPage({Key key, this.coin}) : super(key: key);

  final Coin coin;

  @override
  _ForecastPageState createState() => new _ForecastPageState();

}

class _ForecastPageState extends State<ForecastPage> {

  static const platform = const MethodChannel('samples.flutter.io/battery');
  Map<String, List> data;
  double max;
  double min;
  double diff;
  bool isLoading = true;
  String _batteryLevel = 'Unknown battery level.';

  Future<String> getData() async {
    var response = await http.get(
        Uri.encodeFull("https://coinbin.org/" + widget.coin.symbol + "/forecast"),
        headers: {
          "Accept": "application/json"
        }
    );

    this.setState(() {
      data = JSON.decode(response.body);
      isLoading = false;
      max = data['forecast'][0]['usd'];
      min = data['forecast'][0]['usd'];
      data['forecast'].forEach((value) {
        max < value['usd'] ? max = value['usd'] : max;
        min > value['usd'] ? min = value['usd'] : min;
      });
      print(max.toString());
      print(min.toString());
      print(diff = max - min);
    });

    return "Success!";
  }

  Future<Null> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  Future<Null> _getOnePlusOne() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getOnePlusOne');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  void initState() {
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.coin.name),
        centerTitle: true,
      ),
      body: isLoading ? showProgressIndicator() : new RefreshIndicator(
        child: new ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: data['forecast'] == null ? 0 : 7,
          itemBuilder: _itemBuilder,
        ),
        onRefresh: getData,
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    Forecast forecast = getPrice(index);
    return new ForecastItemWidget(forecast: forecast);
  }

  Widget showProgressIndicator() {
    return new Center(
      child: Platform.isAndroid ? new CircularProgressIndicator() : new CupertinoActivityIndicator(),
    );
  }

  Forecast getPrice(int index) {
    return new Forecast(
      data['forecast'][index]['timestamp'],
      data['forecast'][index]['usd'],
      data['forecast'][index]['when'],
    );
  }

}

class ForecastItemWidget extends StatefulWidget {

  ForecastItemWidget({Key key, this.forecast}) : super(key: key);

  final Forecast forecast;

  @override
  _ForecastItemWidgetState createState() => new _ForecastItemWidgetState();

}

class _ForecastItemWidgetState extends State<ForecastItemWidget> {

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Text(widget.forecast.usd.toString()),
      ],
    );
  }

}