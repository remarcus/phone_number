import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PhoneNumberPlugin {
  static const _channel = const MethodChannel('com.julienvignali.phone_number');

  static Future<ParseResult> parseAndKeepRawInput({
    @required String number,
    String region,
  }) {
    final args = {'number': number, 'region': region};
    return _channel
        .invokeMapMethod<String, dynamic>('parseAndKeepRawInput', args)
        .then(ParseResult.fromMap);
  }
}

class ParseResult {
  final int countryCode;
  final CountryCodeSource countryCodeSource;
  final bool italianLeadingZero;
  final String rawInput;
  final String extension;
  final int nationalNumber;
  final bool isPossibleNumber;
  final bool isValidNumber;
  final String region;
  final PhoneNumberType type;
  final Formats formats;

  ParseResult._({
    this.rawInput,
    this.formats,
    this.italianLeadingZero,
    this.countryCode,
    this.countryCodeSource,
    this.extension,
    this.nationalNumber,
    this.isPossibleNumber,
    this.isValidNumber,
    this.region,
    this.type,
  });

  static ParseResult fromMap(map) {
    return ParseResult._(
      countryCodeSource: toCountryCodeSource(map['countryCodeSource']),
      rawInput: map['rawInput'],
      italianLeadingZero: map['italianLeadingZero'],
      countryCode: map['countryCode'],
      extension: map['extension'],
      nationalNumber: map['nationalNumber'],
      isPossibleNumber: map['isPossibleNumber'],
      isValidNumber: map['isValidNumber'],
      region: map['region'],
      type: toPhoneNumberType(map['type']),
      formats: Formats.fromMap(map['formats']),
    );
  }

  bool get isFixedLine => type == PhoneNumberType.fixedLine;
  bool get isMobile => type == PhoneNumberType.mobile;
  bool get isFixedOrMobile => type == PhoneNumberType.fixedLineOrMobile;
  bool get isTollFree => type == PhoneNumberType.tollFree;
  bool get isPremiumRate => type == PhoneNumberType.premiumRate;
  bool get isSharedCost => type == PhoneNumberType.sharedCost;
  bool get isVoIp => type == PhoneNumberType.voIp;
  bool get isPersonal => type == PhoneNumberType.personal;
  bool get isPager => type == PhoneNumberType.pager;
  bool get isUan => type == PhoneNumberType.uan;
  bool get isVoiceMail => type == PhoneNumberType.voiceMail;
  bool get isUnknown => type == PhoneNumberType.unknown;

  @override
  String toString() {
    return """
ParseResult {
  countryCode: $countryCode, 
  countryCodeSource: $countryCodeSource, 
  italianLeadingZero: $italianLeadingZero, 
  rawInput: $rawInput, 
  extension: $extension, 
  nationalNumber: $nationalNumber, 
  isPossibleNumber: $isPossibleNumber, 
  isValidNumber: $isValidNumber, 
  region: $region, 
  type: $type, 
  formats: $formats
}
    """;
  }
}

class Formats {
  final String e164;
  final String national;
  final String international;
  final String rfc3966;

  Formats._({
    this.e164,
    this.national,
    this.international,
    this.rfc3966,
  });

  static Formats fromMap(map) {
    return Formats._(
      e164: map['e164'],
      national: map['national'],
      international: map['international'],
      rfc3966: map['rfc3966'],
    );
  }

  @override
  String toString() {
    return 'Formats{e164: $e164, national: $national, international: $international, rfc3966: $rfc3966}';
  }
}

enum PhoneNumberType {
  fixedLine, // 0
  mobile, // 1
  fixedLineOrMobile, // 2
  tollFree, // 3
  premiumRate, // 4
  sharedCost, // 5
  voIp, // 6
  personal, // 7
  pager, // 8
  uan, // 9
  voiceMail, // 10
  unknown, // -1
}

enum CountryCodeSource {
  fromNumberWithPlusSign, // 1
  fromNumberWithIdd, // 5,
  fromNumberWithoutPlusSign, // 10,
  fromDefaultCountry, // 20
}

PhoneNumberType toPhoneNumberType(int i) {
  if (i == 0) return PhoneNumberType.fixedLine;
  if (i == 1) return PhoneNumberType.mobile;
  if (i == 2) return PhoneNumberType.fixedLineOrMobile;
  if (i == 3) return PhoneNumberType.tollFree;
  if (i == 4) return PhoneNumberType.premiumRate;
  if (i == 5) return PhoneNumberType.sharedCost;
  if (i == 6) return PhoneNumberType.voIp;
  if (i == 7) return PhoneNumberType.personal;
  if (i == 8) return PhoneNumberType.pager;
  if (i == 9) return PhoneNumberType.uan;
  if (i == 10) return PhoneNumberType.voiceMail;
  return PhoneNumberType.unknown;
}

CountryCodeSource toCountryCodeSource(int i) {
  if (i == 1) return CountryCodeSource.fromNumberWithPlusSign;
  if (i == 5) return CountryCodeSource.fromNumberWithIdd;
  if (i == 10) return CountryCodeSource.fromNumberWithoutPlusSign;
  if (i == 20) return CountryCodeSource.fromDefaultCountry;
  return null;
}
