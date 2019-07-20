import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone_number/phone_number_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _plugin = PhoneNumberPlugin();
  TextEditingController _numberController = TextEditingController();
  TextEditingController _countryCodeController = TextEditingController();

  ParseResult _result;
  String _parseError;

  @override
  void initState() {
    super.initState();
  }

  void _parse() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    try {
      final num = _numberController.value.text;
      final countryCode = _countryCodeController.value.text;
      final res = await _plugin.parseAndKeepRawInput(
        number: num,
        region: countryCode,
      );
      _result = res;
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
        body: SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _countryCodeController,
                          maxLength: 2,
                          decoration: InputDecoration(
                            labelText: "Region",
                            helperText: "2-letter country code",
                            hintText: "ZZ",
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _numberController,
                          decoration: InputDecoration(
                            labelText: "Number",
                            errorText: _parseError,
                            helperText: '',
                          ),
                        ),
                      ),
                    ],
                  ),
                  RaisedButton(
                    child: Text("Parse (parseAndKeepInput)"),
                    onPressed: _parse,
                  ),
                  Divider(),
                  _result != null ? resultTable(_result) : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget resultTable(ParseResult result) {
    final data = <MapEntry>[
      MapEntry("Raw input", "${result.rawInput}"),
      MapEntry("Country code", "${result.countryCode}"),
      MapEntry("Region", "${result.region}"),
      MapEntry("Country code source", sourceToString(result.countryCodeSource)),
      MapEntry("Italian leading zero", result.italianLeadingZero),
      MapEntry("Extension", "${result.extension}"),
      MapEntry("National number", result.nationalNumber),
      MapEntry("Possible number?", result.isPossibleNumber),
      MapEntry("Valid?", result.isValidNumber),
      MapEntry("Type", typeToString(result.type)),
      MapEntry("E164 format:", result.formats.e164),
      MapEntry("International format", result.formats.international),
      MapEntry("National format", result.formats.national),
      MapEntry("RFC3966 format", result.formats.rfc3966),
    ];
    final style = Theme.of(context).textTheme.body1.copyWith(fontSize: 16);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: data
          .map((e) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: RichText(
                  text: TextSpan(
                    style: style,
                    children: [
                      TextSpan(
                        text: "${e.key}\n",
                        style: style.copyWith(
                          fontSize: 13,
                          height: 1.2,
                          letterSpacing: -.5,
                        ),
                      ),
                      TextSpan(
                          text: e.value.toString(),
                          style: style.copyWith(
                              fontWeight: FontWeight.bold,
                              color: e.value is bool
                                  ? (e.value == true ? Colors.blue : Colors.red)
                                  : Colors.black)),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

String typeToString(PhoneNumberType type) {
  if (type == PhoneNumberType.fixedLine) return "Fixed line";
  if (type == PhoneNumberType.fixedLineOrMobile) return "Fixed line or mobile";
  if (type == PhoneNumberType.mobile) return "Mobile";
  if (type == PhoneNumberType.tollFree) return "Toll free";
  if (type == PhoneNumberType.premiumRate) return "Premium rate";
  if (type == PhoneNumberType.sharedCost) return "Shared cost";
  if (type == PhoneNumberType.personal) return "Personal";
  if (type == PhoneNumberType.voIp) return "VOIP";
  if (type == PhoneNumberType.voiceMail) return "Voicemail";
  if (type == PhoneNumberType.pager) return "Pager";
  if (type == PhoneNumberType.uan) return "UAN";
  return "Unknown";
}

String sourceToString(CountryCodeSource source) {
  if (source == CountryCodeSource.fromDefaultCountry) return "Default Country";
  if (source == CountryCodeSource.fromNumberWithIdd) return "Number with IDD";
  if (source == CountryCodeSource.fromNumberWithoutPlusSign)
    return "Number without + sign";
  if (source == CountryCodeSource.fromNumberWithPlusSign)
    return "Number with + sign";
  return "Unknown";
}
