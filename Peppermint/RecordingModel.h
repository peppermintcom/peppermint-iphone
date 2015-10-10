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
-(void) accessRightsAreNotSupplied;
-(void) accessRightsAreSupplied;
-(void) timerUpdated:(NSTimeInterval) timeInterval;
@end

@interface RecordingModel : BaseModel <AVAudioRecorderDelegate>
@property (weak, nonatomic) id<RecordingModelDelegate> delegate;
@property (strong, nonatomic) NSURL *fileUrl;
@property (nonatomic) BOOL grantedForMicrophone;

-(void) record;
-(void) pause;
-(void) resume;
-(void) stop;
-(NSTimeInterval) recordingTime;

@end
