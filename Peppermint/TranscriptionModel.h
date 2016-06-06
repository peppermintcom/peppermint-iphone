//
//  TranscriptionModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 25/05/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"

@interface TranscriptionModel : BaseModel
@property (strong, nonatomic) NSDictionary *supportedLanguageCodesDictionary;
-(NSString*) transctiptionLanguageCode;
@end
