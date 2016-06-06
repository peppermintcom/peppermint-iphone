//
//  AACFileWriter.h
//  Speech
//
//  Created by Okan Kurtulus on 19/05/16.
//  Copyright © 2016 Google. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPAACAudioConverter.h"
#import "BaseModel.h"

@protocol AACFileWriterDelegate <BaseModelDelegate>
-(void) fileConversionIsFinished;
@end

@interface AACFileWriter : BaseModel <TPAACAudioConverterDelegate, TPAACAudioConverterDataSource>
@property (nonatomic, weak) id<AACFileWriterDelegate> delegate;
@property (nonatomic, strong, readonly) NSMutableData *audioData;

-(void) appendData:(NSData*)data;
-(void) convertToAACWithAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd andFileUrl:(NSURL*)fileUrl;

@end
