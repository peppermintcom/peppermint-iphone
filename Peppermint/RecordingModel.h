//
//  RecordingModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 27/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import <AVFoundation/AVFoundation.h>

#define PING_INTERVAL   0.05

@protocol RecordingModelDelegate <BaseModelDelegate>
@required
-(void) microphoneAccessRightsAreNotSupplied;
-(void) accessRightsAreSupplied;
-(void) timerUpdated:(NSTimeInterval) timeInterval;
-(void) recordDataIsPrepared:(NSData*) data withExtension:(NSString*) extension;
@optional
-(void) meteringUpdatedWithAverage:(CGFloat)average andPeak:(CGFloat)peak;
@end

@interface RecordingModel : BaseModel <AVAudioRecorderDelegate>
@property (weak, nonatomic) id<RecordingModelDelegate> delegate;
@property (strong, nonatomic) NSURL *fileUrl;
@property (nonatomic, strong) NSString *transcriptionText;
@property (nonatomic, strong) NSNumber *transcriptionConfidence;

+(CGFloat) checkPreviousFileLength;
+(void) setPreviousFileLength:(CGFloat) previousFileLength;
+(BOOL) checkRecordPermissions;

-(void) record;
-(void) pause;
-(void) resume;
-(void) stop;

-(void) backUpRecording;
-(void) resetRecording;
-(void) prepareRecordData;

-(void) cleanCache;

@end
