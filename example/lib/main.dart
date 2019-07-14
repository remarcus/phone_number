import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone_number/phone_number_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController _numberController = TextEditingController();
  TextEditingController _countryCodeController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  String _parseError;
  String _parsed;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      print("scroll");
    });
  }

  void _parse() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    try {
      final num = _numberController.value.text;
      final countryCode = _countryCodeController.value.text;
      final res = await PhoneNumberPlugin.parseAndKeepRawInput(
        number: num,
        region: countryCode,
      );
      _parsed = res.toString();
      _parseError = null;
    } on PlatformException catch (e) {
      _parseError = e.code;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Phone Number Parser')),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _countryCodeController,
                  maxLength: 2,
                ),
                TextField(
                  controller: _numberController,
                  decoration: InputDecoration(errorText: _parseError),
                ),
                RaisedButton(
                  child: Text("Parse (parseAndKeepInput)"),
                  onPressed: _parse,
                ),
                Center(child: Text(_parsed ?? '')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
