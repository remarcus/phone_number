#import "PhoneNumberPlugin.h"
#import <libPhoneNumber-iOS/NBPhoneNumberUtil.h>
#import <libPhoneNumber-iOS/NBPhoneNumber.h>
#import <libPhoneNumber-iOS/NBAsYouTypeFormatter.h>

@implementation PhoneNumberPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
                                   methodChannelWithName:@"com.julienvignali.phone_number"
                                   binaryMessenger:[registrar messenger]];
  PhoneNumberPlugin* instance = [[PhoneNumberPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"parseAndKeepRawInput" isEqualToString:call.method]) {
    [self parseAndKeepRawInput:call result:result];
  }
  else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)parseAndKeepRawInput:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSLog(@"%s", __PRETTY_FUNCTION__);
  NSString * number = call.arguments[@"number"];
  NSString * region = call.arguments[@"region"];
  NBPhoneNumberUtil * util = NBPhoneNumberUtil.sharedInstance;
  
  NSError * parseError;
  NBPhoneNumber * phoneNumber = [util parseAndKeepRawInput:number defaultRegion:region error:&parseError];
  if (parseError == nil) {
    NSLog(@"PhoneNumber parsed!");
    
    NSMutableDictionary * map = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 phoneNumber.rawInput, @"rawInput",
                                 phoneNumber.countryCode, @"countryCode",
                                 phoneNumber.nationalNumber, @"nationalNumber",
                                 phoneNumber.extension ?: @"", @"extension",
                                 @(phoneNumber.italianLeadingZero), @"italianLeadingZero",
                                 phoneNumber.countryCodeSource, @"countryCodeSource",
                                 @([util isValidNumber:phoneNumber]), @"isValidNumber",
                                 @([util isPossibleNumber:phoneNumber]), @"isPossibleNumber",
                                 @([util getNumberType:phoneNumber]), @"type",
                                 [util getRegionCodeForNumber:phoneNumber], @"region",
                                 nil];
    
    NSError * formatError;
    NSString * e164 = [util format:phoneNumber numberFormat:NBEPhoneNumberFormatE164 error:&formatError];
    NSString * intl = [util format:phoneNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL error:&formatError];
    NSString * natl = [util format:phoneNumber numberFormat:NBEPhoneNumberFormatNATIONAL error:&formatError];
    NSString * rfc = [util format:phoneNumber numberFormat:NBEPhoneNumberFormatRFC3966 error:&formatError];
    
    if (formatError == nil) {
      map[@"formats"] = @{@"e164": e164,
                          @"national": natl,
                          @"international": intl,
                          @"rfc3966": rfc};
    }
    result(map);
  }
  else {
    NSLog(@"Parse error: %@", parseError.domain);
    result([FlutterError errorWithCode:parseError.domain message:@"" details:nil]);
  }
}

@end
