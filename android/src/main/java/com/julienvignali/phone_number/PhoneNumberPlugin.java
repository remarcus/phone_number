package com.julienvignali.phone_number;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.google.i18n.phonenumbers.NumberParseException;
import com.google.i18n.phonenumbers.PhoneNumberUtil;
import com.google.i18n.phonenumbers.PhoneNumberUtil.PhoneNumberType;
import com.google.i18n.phonenumbers.Phonenumber.PhoneNumber.CountryCodeSource;
import com.google.i18n.phonenumbers.Phonenumber.PhoneNumber;

import java.util.HashMap;


public class PhoneNumberPlugin implements MethodCallHandler {
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "com.julienvignali.phone_number");
        channel.setMethodCallHandler(new PhoneNumberPlugin());
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("parseAndKeepRawInput")) {
            parseAndKeepRawInput(call, result);
        } else {
            result.notImplemented();
        }
    }

    private void parseAndKeepRawInput(MethodCall call, Result result) {
        final PhoneNumberUtil util = PhoneNumberUtil.getInstance();
        try {
            final String region = call.argument("region");
            String number = call.argument("number");
            final PhoneNumber phoneNumber = util.parseAndKeepRawInput(number, region);

            final HashMap<String, String> formats = new HashMap<String, String>() {{
                put("e164", util.format(phoneNumber, PhoneNumberUtil.PhoneNumberFormat.E164));
                put("international", util.format(phoneNumber, PhoneNumberUtil.PhoneNumberFormat.INTERNATIONAL));
                put("national", util.format(phoneNumber, PhoneNumberUtil.PhoneNumberFormat.NATIONAL));
                put("rfc3966", util.format(phoneNumber, PhoneNumberUtil.PhoneNumberFormat.RFC3966));
            }};

            HashMap<String, Object> map = new HashMap<String, Object>() {{
                put("rawInput", phoneNumber.getRawInput());
                put("countryCode", phoneNumber.getCountryCode());
                put("extension", phoneNumber.getExtension());
                put("nationalNumber", phoneNumber.getNationalNumber());
                put("italianLeadingZero", phoneNumber.isItalianLeadingZero());
                put("countryCodeSource", countryCodeSourceToInt(phoneNumber.getCountryCodeSource()));
                put("isValidNumber", util.isValidNumber(phoneNumber));
                put("isPossibleNumber", util.isPossibleNumber(phoneNumber));
                put("isValidNumberForRegion", util.isValidNumberForRegion(phoneNumber, region));
                put("type", numberTypeToInt(util.getNumberType(phoneNumber)));
                put("region", util.getRegionCodeForNumber(phoneNumber));
                put("e164", util.format(phoneNumber, PhoneNumberUtil.PhoneNumberFormat.E164));
                put("international", util.format(phoneNumber, PhoneNumberUtil.PhoneNumberFormat.INTERNATIONAL));
                put("national", util.format(phoneNumber, PhoneNumberUtil.PhoneNumberFormat.NATIONAL));
                put("formats", formats);

            }};
            result.success(map);
        } catch (NumberParseException e) {
            result.error(e.getErrorType().name(), e.getLocalizedMessage(), null);
        }
    }

    private int numberTypeToInt(PhoneNumberType type) {
        switch (type) {
            case FIXED_LINE:
                return 0;
            case MOBILE:
                return 1;
            case FIXED_LINE_OR_MOBILE:
                return 2;
            case TOLL_FREE:
                return 3;
            case PREMIUM_RATE:
                return 4;
            case SHARED_COST:
                return 5;
            case VOIP:
                return 6;
            case PERSONAL_NUMBER:
                return 7;
            case PAGER:
                return 8;
            case UAN:
                return 9;
            case VOICEMAIL:
                return 10;
            default:
                return -1;
        }
    }

    private int countryCodeSourceToInt(CountryCodeSource source) {
        switch (source) {
            case FROM_DEFAULT_COUNTRY:
                return 20;
            case FROM_NUMBER_WITHOUT_PLUS_SIGN:
                return 10;
            case FROM_NUMBER_WITH_PLUS_SIGN:
                return 1;
            case FROM_NUMBER_WITH_IDD:
                return 5;
            case UNSPECIFIED:
            default:
                return -1;
        }
    }
}
