//
//  RecordingModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 27/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import <AVFoundation/AVFoundation.h>

@protocol RecordingModelDelegate <BaseModelDelegate>
@required
-(void) microphoneAccessRightsAreNotSupplied;
-(void) accessRightsAreSupplied;
-(void) timerUpdated:(NSTimeInterval) timeInterval;
-(void) recordDataIsPrepared:(NSData*) data;
@end

@interface RecordingModel : BaseModel <AVAudioRecorderDelegate>
@property (weak, nonatomic) id<RecordingModelDelegate> delegate;
@property (strong, nonatomic) NSURL *fileUrl;
@property (nonatomic) BOOL grantedForMicrophone;
@property (nonatomic) NSUInteger previousFileLength;

-(void) record;
-(void) pause;
-(void) resume;
-(void) stop;

-(void) backUpRecording;
-(void) resetRecording;
-(void) prepareRecordData;
@end
