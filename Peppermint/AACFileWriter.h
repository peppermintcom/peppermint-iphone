//
//  AACFileWriter.h
//  Speech
//
//  Created by Okan Kurtulus on 19/05/16.
//  Copyright © 2016 Google. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPAACAudioConverter.h"

@interface AACFileWriter : NSObject <TPAACAudioConverterDelegate, TPAACAudioConverterDataSource>
@property (nonatomic, strong, readonly) NSMutableData *audioData;

-(void) appendData:(NSData*)data;
-(void) convertToAACWithAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd;

@end
