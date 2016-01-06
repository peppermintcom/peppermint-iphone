//
//  RecordingView.m
//  Peppermint
//
//  Created by Okan Kurtulus on 15/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "RecordingView.h"

typedef enum : NSUInteger {
    RecordingViewStatusResignActive,
    RecordingViewStatusRecoverFromBackUp,
    RecordingViewStatusPresented,
    RecordingViewStatusInit,
    RecordingViewStatusFinishing,
} RecordingViewStatus;

@implementation RecordingView {
    RecordingViewStatus recordingViewStatus;
}

#pragma mark - Must to override Functions

+(RecordingView*) createInstanceWithDelegate:(UIViewController<RecordingViewDelegate>*) delegate {
    @throw override_error;
}

-(void) dissmissWithFadeOut {
    NSLog(@"dissmissWithFadeOut");
    @throw override_error;
}

-(void) dissmissWithExplode {
    NSLog(@"dissmissWithExplode");
    @throw override_error;
}

#pragma mark - Prepare View

- (void)awakeFromNib {
    self.hidden = YES;
    recordingViewStatus = RecordingViewStatusInit;
    defaults_set_object(DEFAULTS_KEY_PREVIOUS_RECORDING_LENGTH, 0);
    REGISTER();
}

#pragma mark - Record Methods

-(BOOL) presentWithAnimationInRect:(CGRect)rect onPoint:(CGPoint) point {
    if(recordingViewStatus == RecordingViewStatusInit) {
        recordingViewStatus = RecordingViewStatusPresented;
        assert(self.sendVoiceMessageModel != nil);
        self.sendVoiceMessageModel.delegate = self;
        self.recordingModel = [RecordingModel new];
        self.recordingModel.delegate = self;
        return YES;
    }
    return NO;
}

-(BOOL) finishRecordingWithGestureIsValid:(BOOL) isGestureValid {
    BOOL result = NO;
    if(recordingViewStatus == RecordingViewStatusPresented) {
        recordingViewStatus = RecordingViewStatusFinishing;
        [self.recordingModel stop];
        
        BOOL isRecordingLong = self.totalSeconds >= MAX_RECORD_TIME;
        BOOL isRecordingShort = self.totalSeconds <= MIN_VOICE_MESSAGE_LENGTH;
        
        if (isRecordingLong) {
            NSLog(@"Max time reached..."); //This action is handled in "timerUpdated:" delegate method
        } else if(!isGestureValid) {
            [self dissmissWithExplode];
        } else if (isRecordingShort) {
            [self showAlertToRecordMoreThanMinimumMessageLength];
        } else {
            [self dissmissWithFadeOut];
            [self performOperationsToSend];
        }
    } else {
        NSLog(@"RecordingView is not presented!");
    }
    return result;
}

-(void) cancelMessageSending {
    [self.sendVoiceMessageModel cancelSending];
}

-(void) recordingViewIsHidden {
    recordingViewStatus = RecordingViewStatusInit;
    [self.delegate recordingViewDissappeared];
}

#pragma mark - PerformOperationsToSend

-(void) performOperationsToSend {
    [self.sendVoiceMessageModel messagePrepareIsStarting];
    [self.recordingModel prepareRecordData];
}

#pragma mark - Record Actions

-(void) beginRecording {
    [self.recordingModel stop];
    [self.recordingModel record];
}

#pragma mark - RecordingModel Delegate

-(void) microphoneAccessRightsAreNotSupplied {
    NSString *title = LOC(@"Information", @"Title Message");
    NSString *message = LOC(@"Mic Access rights explanation", @"Directives to give access rights") ;
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
    NSString *settingsButtonTitle = LOC(@"Settings", @"Settings Message");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:settingsButtonTitle, nil] show];
}

-(void) accessRightsAreSupplied {
    if(recordingViewStatus == RecordingViewStatusPresented) {
        [self.recordingModel resetRecording];
        if([RecordingModel checkPreviousFileLength] < MIN_VOICE_MESSAGE_LENGTH) {
            [self.playingModel playBeginRecording];
            [self beginRecording];
        } else {
            [self showAlertForRecordIsCut];
        }
    } else {
        NSLog(@"Fastrecording view is not in presented state! Will not show!");
    }
}

-(void) timerUpdated:(NSTimeInterval) timeInterval {
    self.totalSeconds = timeInterval;
    self.currentMinutes = self.totalSeconds / 60;
    self.currentSeconds = ((int)self.totalSeconds) % 60;
    if(self.totalSeconds > MAX_RECORD_TIME) {
        [self.recordingModel stop];
        [self showTimeFinishedInformation];
    }
}

- (void) showTimeFinishedInformation {
    NSString *title = LOC(@"Information", @"Information");
    NSString *message = LOC(@"Time is up", @"Max time reached information message");
    NSString *cancelButtonTitle = LOC(@"Cancel", @"Cancel");
    NSString *sendButtonTitle = LOC(@"Send", @"Send Message");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:sendButtonTitle, nil] show];
}

- (void) recordDataIsPrepared:(NSData *)data withExtension:(NSString*) extension {
    [self.sendVoiceMessageModel sendVoiceMessageWithData:data withExtension:extension  andDuration:self.totalSeconds];
}

#pragma mark - SendVoiceMessage Delegate

-(void) newRecentContactisSaved {
    [self.delegate newRecentContactisSaved];
}

#pragma mark - Minimum Message Length Warning

-(void) showAlertToRecordMoreThanMinimumMessageLength {
    MBProgressHUD * hud =  [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeText;
    
    hud.detailsLabelFont = [UIFont openSansSemiBoldFontOfSize:22];
    hud.detailsLabelText = [NSString stringWithFormat:LOC(@"Record More Than Limit Format", @"Format of minimum recording warning text"),
                            MIN_VOICE_MESSAGE_LENGTH];
    hud.removeFromSuperViewOnHide = YES;
    hud.yOffset -= (self.frame.size.height * 0.075);
    hud.userInteractionEnabled = YES;
    hud.gestureRecognizers = [NSArray arrayWithObject:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideAlertToRecordMoreThanMinimumMessageLength)]];
    
    hud.completionBlock = ^{
        [self dissmissWithFadeOut];
    };
    [hud hide:YES afterDelay:WARN_TIME * 2];
}

-(void) hideAlertToRecordMoreThanMinimumMessageLength {
    [MBProgressHUD hideAllHUDsForView:self animated:YES];
}

#pragma mark - AlertView Delegate

-(void) showAlertForRecordIsCut {
    NSString *title = LOC(@"Information", @"Information");
    NSString *message = LOC(@"Recording is cut", @"Recording is cut, how to continue question?");
    NSString *cancel = LOC(@"Cancel", @"Cancel");
    NSString *send = LOC(@"Send", @"Send");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:send, nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([alertView.message isEqualToString: LOC(@"Mic Access rights explanation", @"Directives to give access rights")]) {
        switch (buttonIndex) {
            case ALERT_BUTTON_INDEX_CANCEL:
                [self dissmissWithExplode];
                break;
            case ALERT_BUTTON_INDEX_OTHER_1:
                [self redirectToSettingsPageForPermission];
                break;
            default:
                break;
        }
    } else if ([alertView.message isEqualToString:LOC(@"Recording is cut", @"Recording is cut, how to continue question?")]) {
        [RecordingModel setPreviousFileLength:0];
        switch (buttonIndex) {
            case ALERT_BUTTON_INDEX_CANCEL:
                [self dissmissWithFadeOut];
                //__clear backup files
                break;
            case ALERT_BUTTON_INDEX_OTHER_1:
                [self.recordingModel record];
                recordingViewStatus = RecordingViewStatusPresented;
                [self finishRecordingWithGestureIsValid:YES];
                break;
            default:
                break;
        }
    } if ([alertView.message isEqualToString:LOC(@"Time is up", @"Max time reached information message")]) {
        switch (buttonIndex) {
            case ALERT_BUTTON_INDEX_CANCEL:
                [self dissmissWithExplode];
                break;
            case ALERT_BUTTON_INDEX_OTHER_1:
                [self dissmissWithFadeOut];
                [self performOperationsToSend];
                break;
            default:
                break;
        }
    } else {
        NSLog(@"Unhandled alertview Message: %@", alertView.message);
    }
}

#pragma mark - Message Senging Status Updated

SUBSCRIBE(MessageSendingStatusIsUpdated) {
    //SendVoiceMessageModel *model = [SendVoiceMessageModel activeSendVoiceMessageModel];
    SendVoiceMessageModel *model = event.sender;
    BOOL isCacnelAble = model.delegate != nil && model.isCancelAble;
    if([self shouldInformDelegateAboutStatusUpdateInModel:model]) {
        [self.delegate message:event.sender isUpdatedWithStatus:model.sendingStatus cancelAble:isCacnelAble];
    }
}

-(BOOL) shouldInformDelegateAboutStatusUpdateInModel:(SendVoiceMessageModel*) model {
    BOOL result = ( model.delegate != nil
                   || model.sendingStatus == SendingStatusStarting
                   || model.sendingStatus == SendingStatusUploading
                   || model.sendingStatus == SendingStatusSending
                   || model.sendingStatus == SendingStatusSendingWithNoCancelOption
                   || model.sendingStatus == SendingStatusSent
                   || model.sendingStatus == SendingStatusCached);
    
    //NSLog(@"Model:%@ status:%d delegate:%d isAllowed:%d", model, (int)model.sendingStatus, model.delegate != nil, result);
    return result;
}

#pragma mark - Settings Page

-(void) redirectToSettingsPageForPermission {
    if(UIApplicationOpenSettingsURLString != nil) {
        NSURL *appSettingsUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:appSettingsUrl];
    } else {
        NSString *title = LOC(@"Information", @"Title Message");
        NSString *message = LOC(@"Settings URL is not supported", @"Information Message");
        NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
        [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
    }
}

#pragma mark - App Interruption Actions

SUBSCRIBE(ApplicationWillResignActive) {
    recordingViewStatus = RecordingViewStatusResignActive;
    [self.recordingModel backUpRecording];
}

SUBSCRIBE(ApplicationDidBecomeActive) {
    [self handleAppIsActiveAgain];
}

-(void) handleAppIsActiveAgain {
    if(recordingViewStatus == RecordingViewStatusResignActive) {
        recordingViewStatus = RecordingViewStatusRecoverFromBackUp;
        CGFloat previousFileLength = [RecordingModel checkPreviousFileLength];
        if( previousFileLength > MIN_VOICE_MESSAGE_LENGTH) {
            if(!self.sendVoiceMessageModel) {
                NSError *error = [NSError errorWithDomain:@"sendVoiceMessageModel was released. This message can not be sent! :(" code:-1 userInfo:nil];
                [self.delegate operationFailure:error];
            } else {
                self.sendVoiceMessageModel.delegate = self;
                if(!self.recordingModel) {
                    self.recordingModel = [RecordingModel new];
                    self.recordingModel.delegate = self;
                } else {
                    self.recordingModel.delegate = self;
                    [self showAlertForRecordIsCut];
                }
            }
        } else {
            [RecordingModel setPreviousFileLength:0];
            [self dissmissWithFadeOut];
        }
    }
}

@end
