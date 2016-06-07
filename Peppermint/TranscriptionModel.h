//
//  TranscriptionModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 25/05/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#define DEFAULT_LANGUAGE_CODE @"en-US"

@interface TranscriptionModel : BaseModel
@property (strong, nonatomic) NSDictionary *supportedLanguageCodesDictionary;
-(NSString*) transctiptionLanguageCode;
-(BOOL) setTransctiptionLanguageCode:(NSString*)langCode;
-(NSString*) codeForLanguage:(NSString*)language;
@end
