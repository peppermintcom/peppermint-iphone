//
//  TranscriptionModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 25/05/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "TranscriptionModel.h"

@implementation TranscriptionModel

-(NSDictionary*) supportedLanguageCodesDictionary {
    if(!_supportedLanguageCodesDictionary) {
        _supportedLanguageCodesDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                             @"Afrikaans (Suid-Afrika)",        @"af-ZA",
                                             @"Bahasa Indonesia (Indonesia)",   @"id-ID",
                                             @"Bahasa Melayu (Malaysia)",       @"ms-MY",
                                             @"Català (Espanya)",               @"ca-ES",
                                             @"Čeština (Česká republika)",      @"cs-CZ",
                                             @"Dansk (Danmark)",                @"da-DK",
                                             @"Deutsch (Deutschland)",          @"de-DE",
                                             @"English (Australia)",            @"en-AU",
                                             @"English (Canada)",               @"en-CA",
                                             @"English (Great Britain)",        @"en-GB",
                                             @"English (India)",                @"en-IN",
                                             @"English (Ireland)",              @"en-IE",
                                             @"English (New Zealand)",          @"en-NZ",
                                             @"English (Philippines)",          @"en-PH",
                                             @"English (South Africa)",         @"en-ZA",
                                             @"English (United States)",        @"en-US",
                                             @"Español (Argentina)",            @"es-AR",
                                             @"Español (Bolivia)",              @"es-BO",
                                             @"Español (Chile)",                @"es-CL",
                                             @"Español (Colombia)",             @"es-CO",
                                             @"Español (Costa Rica)",           @"es-CR",
                                             @"Español (Ecuador)",              @"es-EC",
                                             @"Español (El Salvador)",          @"es-SV",
                                             @"Español (España)",               @"es-ES",
                                             @"Español (Estados Unidos)",       @"es-US",
                                             @"Español (Guatemala)",            @"es-GT",
                                             @"Español (Honduras)",             @"es-HN",
                                             @"Español (México)",               @"es-MX",
                                             @"Español (Nicaragua)",            @"es-NI",
                                             @"Español (Panamá)",               @"es-PA",
                                             @"Español (Paraguay)",             @"es-PY",
                                             @"Español (Perú)",                 @"es-PE",
                                             @"Español (Puerto Rico)",          @"es-PR",
                                             @"Español (República Dominicana)",	@"es-DO",
                                             @"Español (Uruguay)",              @"es-UY",
                                             @"Español (Venezuela)",            @"es-VE",
                                             @"Euskara (Espainia)",             @"eu-ES",
                                             @"Filipino (Pilipinas)",           @"fil-PH",
                                             @"Français (France)",              @"fr-FR",
                                             @"Galego (España)",                @"gl-ES",
                                             @"Hrvatski (Hrvatska)",            @"hr-HR",
                                             @"IsiZulu (Ningizimu Afrika)",     @"zu-ZA",
                                             @"Íslenska (Ísland)",              @"is-IS",
                                             @"Italiano (Italia)",              @"it-IT",
                                             @"Lietuvių (Lietuva)",             @"lt-LT",
                                             @"Magyar (Magyarország)",          @"hu-HU",
                                             @"Nederlands (Nederland)",         @"nl-NL",
                                             @"Norsk bokmål (Norge)",           @"nb-NO",
                                             @"Polski (Polska)",                @"pl-PL",
                                             @"Português (Brasil)",             @"pt-BR",
                                             @"Português (Portugal)",           @"pt-PT",
                                             @"Română (România)",               @"ro-RO",
                                             @"Slovenčina (Slovensko)",         @"sk-SK",
                                             @"Slovenščina (Slovenija)",        @"sl-SI",
                                             @"Suomi (Suomi)",                  @"fi-FI",
                                             @"Svenska (Sverige)",              @"sv-SE",
                                             @"Tiếng Việt (Việt Nam)",          @"vi-VN",
                                             @"Türkçe (Türkiye)",               @"tr-TR",
                                             @"Ελληνικά (Ελλάδα)",              @"el-GR",
                                             @"Български (България)",           @"bg-BG",
                                             @"Русский (Россия)",               @"ru-RU",
                                             @"Српски (Србија)",                @"sr-RS",
                                             @"Українська (Україна)",           @"uk-UA",
                                             @"עברית (ישראל)",       	@"he-IL",
                                             @"العربية (إسرائيل)",	@"ar-IL",
                                             @"العربية (الأردن)",	@"ar-JO",
                                             @"العربية (الإمارات)",	@"ar-AE",
                                             @"العربية (البحرين)",	@"ar-BH",
                                             @"العربية (الجزائر)",	@"ar-DZ",
                                             @"العربية (السعودية)",	@"ar-SA",
                                             @"العربية (العراق)",	@"ar-IQ",
                                             @"العربية (الكويت)",	@"ar-KW",
                                             @"العربية (المغرب)",	@"ar-MA",
                                             @"العربية (تونس)",	@"ar-TN",
                                             @"العربية (عُمان)",	@"ar-OM",
                                             @"العربية (فلسطين)",	@"ar-PS",
                                             @"العربية (قطر)",	@"ar-QA",
                                             @"العربية (لبنان)",	@"ar-LB",
                                             @"العربية (مصر)",	@"ar-EG",
                                             @"فارسی (ایران)",	@"fa-IR",
                                             @"हिन्दी (भारत)",	@"hi-IN",
                                             @"ไทย (ประเทศไทย)",	@"th-TH",
                                             @"한국어 (대한민국)",	@"ko-KR",
                                             @"國語 (台灣)	",	@"cmn-Hant-TW",
                                             @"廣東話 (香港)",	@"yue-Hant-HK",
                                             @"日本語（日本）",	@"ja-JP",
                                             @"普通話 (香港)",	@"cmn-Hans-HK",
                                             @"普通话 (中国大陆)",	@"cmn-Hans-CN",
                                             nil];
        
    }
    return _supportedLanguageCodesDictionary;
}

-(NSString*) transctiptionLanguageCode {
    NSString *defaultLanguageCode = LOC(@"Transcription Preffered Default Language", @"Transcription Preffered Default Language");
    NSString *systemLanguageCode = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSArray *supportedLanguageCodes = self.supportedLanguageCodesDictionary.allKeys;
    
    NSString *languageCode = @"en-US";
    if([supportedLanguageCodes containsObject:systemLanguageCode]) {
        languageCode = systemLanguageCode;
    } else if (![defaultLanguageCode isEqualToString:@"Transcription Preffered Default Language"]) {
        languageCode = defaultLanguageCode;
    }
    return languageCode;
}

@end
