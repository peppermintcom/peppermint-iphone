//
//  TranscriptionInfo.h
//  Peppermint
//
//  Created by Okan Kurtulus on 06/06/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RecognizeResponse;

@interface TranscriptionInfo : NSObject
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSNumber *confidence;
@property (nonatomic, strong) NSData *rawAudioData;

-(void) processRecogniseResponse:(RecognizeResponse*) response;

@end
