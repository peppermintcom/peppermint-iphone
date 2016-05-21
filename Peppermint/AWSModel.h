//
//  AWSModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 24/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import "AWSService.h"

@protocol AWSModelDelegate <BaseModelDelegate>
@required
-(void) recorderInitIsSuccessful;
-(void) fileUploadCompletedWithPublicUrl:(NSString*) url canonicalUrl:(NSString*)canonicalUrl;
@optional
-(void) sendInterAppMessageIsCompletedWithSuccess;
-(void) sendInterAppMessageIsCompletedWithError:(NSError*)error;
-(void) sendInterAppMessageWasUnauthorised;
@end

@interface AWSModel : BaseModel
@property (weak, nonatomic) id<AWSModelDelegate> delegate;

-(void) initRecorder;
-(void) startToUploadData:(NSData*) data ofType:(NSString*) contentType;

#pragma mark - Update GCM Registration Token
- (void) tryToUpdateGCMRegistrationToken;
#pragma mark - Set Up Recorder With Account
- (void) tryToSetUpAccountWithRecorder;
#pragma mark - Send Inter App Message
-(void) sendInterAppMessageTo:(NSString*)toEmail from:(NSString*)fromEmail withTranscriptionUrl:(NSString*)transcriptionUrl audioUrl:(NSString*)audioUrl;
#pragma mark - Transcription
-(void) saveTranscriptionWithAudioUrl:(NSString*)audioUrl transcriptionText:(NSString*)transcriptionText confidence:(NSNumber*) confidence;
@end
