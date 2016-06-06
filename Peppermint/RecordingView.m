//
//  RecordingView.m
//  Peppermint
//
//  Created by Okan Kurtulus on 15/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "RecordingView.h"
#import "LoginNavigationViewController.h"
#import "SMSChargeWarningView.h"
#import "SendVoiceMessageSparkPostModel.h"

#import "AVAudioRecordingModel.h"
#import "GoogleSpeechRecordingModel.h"

#define LATENCY_TO_RECOVER          3
#define LATENCY_TO_SYSTEM_CANCEL    2

typedef enum : NSUInteger {
    RecordingViewStatusResignActive,
    RecordingViewStatusRecoverFromBackUp,
    RecordingViewStatusPresented,
    RecordingViewStatusInit,
    RecordingViewStatusFinishing,
} RecordingViewStatus;

@interface RecordingView() <LoginNavigationViewControllerDelegate, SMSChargeWarningViewDelegate>

@end

@implementation RecordingView {
    RecordingViewStatus recordingViewStatus;
    NSData *audioData;
    NSString *audioDataExtension;
    NSInteger cachedSeconds;
    SMSChargeWarningView *smsChargeWarningView;
    UIButton *sendCachedMessageButton;
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
    _recordingModel = nil;
    sendCachedMessageButton = nil;
    recordingViewStatus = RecordingViewStatusInit;
    defaults_set_object(DEFAULTS_KEY_PREVIOUS_RECORDING_LENGTH, 0);
    [self initSMSChargeView];
    REGISTER();
}

#pragma mark - Record Methods

-(BOOL) presentWithAnimationInRect:(CGRect)rect onPoint:(CGPoint) point {
    BOOL isRecordingViewStateValid = (recordingViewStatus == RecordingViewStatusInit);
    BOOL isSMSChargeViewVisible = (smsChargeWarningView && !smsChargeWarningView.hidden);
    
    if(isRecordingViewStateValid && !isSMSChargeViewVisible) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        recordingViewStatus = RecordingViewStatusPresented;
        assert(self.sendVoiceMessageModel != nil);
        self.sendVoiceMessageModel.delegate = self;
        _recordingModel = nil;
        [self recordingModel];
        return YES;
    }
    return NO;
}

-(BOOL) finishRecordingWithGestureIsValid:(BOOL) isGestureValid needsPause:(BOOL)needsPause {
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
        } else if (needsPause) {
            recordingViewStatus = RecordingViewStatusPresented;
            self.sendVoiceMessageModel.sendingStatus = SendingStatusStarting;
            self.hidden = YES;
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
    if(recordingViewStatus != RecordingViewStatusInit && recordingViewStatus != RecordingViewStatusFinishing) {
        NSLog(@"RecordingView is not in a state that is cancellable. Status: %lu", (unsigned long)recordingViewStatus);
    } else if (!self.sendVoiceMessageModel.isCancelAble) {
        NSLog(@"sendVoiceMessageModel is not cancelable");
    } else {
        [self.sendVoiceMessageModel cancelSending];
    }
}

-(void) recordingViewIsHidden {
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    recordingViewStatus = RecordingViewStatusInit;
    [self.delegate recordingViewDissappeared];
}

#pragma mark - PerformOperationsToSend

-(void) performOperationsToSend {
    cachedSeconds = self.totalSeconds;
    
    if(self.sendVoiceMessageModel.selectedPeppermintContact.communicationChannel
       ==  CommunicationChannelSMS) {
        [smsChargeWarningView presentOverView:self
                               forNameSurname:self.sendVoiceMessageModel.selectedPeppermintContact.nameSurname];
    } else {
        [self triggerMessageSendProcess];
    }
}

-(void) triggerMessageSendProcess {
    [self.sendVoiceMessageModel messagePrepareIsStarting];
    [self.recordingModel prepareRecordData];
}

#pragma mark - SMSChargeView

-(void) initSMSChargeView {
    smsChargeWarningView = [SMSChargeWarningView createInstanceWithDelegate:self];
}

#pragma mark - SMSChargeWarningViewDelegate

- (void) userConfirmsToSendSMS {
    [self triggerMessageSendProcess];
}

- (void) sendMailInsteadOfSmsToRecepient:(NSString*) email {
    if(![email isValidEmail]) {
        NSLog(@"%@ is not a valid email", email);
    } else {
        SendVoiceMessageMailClientModel *sendVoiceMessageMailClientModel = [SendVoiceMessageSparkPostModel new];
        sendVoiceMessageMailClientModel.selectedPeppermintContact = self.sendVoiceMessageModel.selectedPeppermintContact;
        sendVoiceMessageMailClientModel.selectedPeppermintContact.communicationChannel = CommunicationChannelEmail;
        sendVoiceMessageMailClientModel.selectedPeppermintContact.communicationChannelAddress = email;
        sendVoiceMessageMailClientModel.peppermintMessageSender = self.sendVoiceMessageModel.peppermintMessageSender;
        self.sendVoiceMessageModel = sendVoiceMessageMailClientModel;
        self.sendVoiceMessageModel.delegate = self;
        [self triggerMessageSendProcess];
        
        CustomContactModel *customContactModel = [CustomContactModel new];
        [customContactModel save:sendVoiceMessageMailClientModel.selectedPeppermintContact];
    };
}

#pragma mark - Record Actions

-(void) beginRecording {
    [self.recordingModel stop];
    [self.recordingModel record];
}

-(void) pause {
    [self.recordingModel pause];
}

-(void) stop {
    [self.recordingModel stop];
}

#pragma mark - RecordingModel Delegate

-(void) microphoneAccessRightsAreNotSupplied {
    NSString *title = LOC(@"Information", @"Title Message");
    NSString *message = LOC(@"Mic Access rights explanation", @"Directives to give access rights") ;
    NSString *cancelButtonTitle = LOC(@"Cancel", @"Cancel Message");
    NSString *settingsButtonTitle = LOC(@"Enable", @"Enable message");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:settingsButtonTitle, nil] show];
}

-(void) accessRightsAreSupplied {
    if(recordingViewStatus == RecordingViewStatusPresented) {
        [self.recordingModel resetRecording];
        weakself_create();
        if([RecordingModel checkPreviousFileLength] < MIN_VOICE_MESSAGE_LENGTH) {
            BOOL play =  [self.playingModel playPreparedAudiowithCompetitionBlock:^{
                if(!weakSelf.hidden
                   && recordingViewStatus == RecordingViewStatusPresented) {
                    [self beginRecording];
                }
            }];
            if(!play) {
                NSError *error = [NSError errorWithDomain:@"Could not play audio" code:-1 userInfo:[NSDictionary new]];
                [self operationFailure:error];
            }
        } else {
            [self showAlertForRecordIsCut];
        }
    } else {
        NSLog(@"Recording view is not in presented state! Will not show!");
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
    
    BOOL isAuthProcessOK =
    !self.sendVoiceMessageModel.needsAuth
    || self.sendVoiceMessageModel.peppermintMessageSender.isValidToSendMessage;
    
    if(isAuthProcessOK) {
        self.sendVoiceMessageModel.transcriptionInfo = self.recordingModel.transcriptionInfo;
        [self.sendVoiceMessageModel sendVoiceMessageWithData:data withExtension:extension  andDuration:cachedSeconds];
    } else {
        audioData = data;
        audioDataExtension = extension;
        self.sendVoiceMessageModel.sendingStatus = SendingStatusCancelled;
        [LoginNavigationViewController logUserInWithDelegate:self completion:nil];
    }
}

#pragma mark - LoginNavigationViewControllerDelegate

-(void) loginSucceedWithMessageSender:(PeppermintMessageSender*) peppermintMessageSender {    
    if(peppermintMessageSender.isValidToSendMessage) {
        NSAssert(cachedSeconds >= MIN_VOICE_MESSAGE_LENGTH
                 && audioData && audioDataExtension , @"Audio data is not ready to send!");
        self.sendVoiceMessageModel.sendingStatus = SendingStatusInited;
        
#warning "Consider updating below line as commented line"
        //[self recordDataIsPrepared:audioData withExtension:audioDataExtension];
        [self.sendVoiceMessageModel sendVoiceMessageWithData:audioData withExtension:audioDataExtension  andDuration:cachedSeconds];
    }
}

#pragma mark - SendVoiceMessage Delegate

-(void) newRecentContactisSaved {
    [self.delegate newRecentContactisSaved];
}

-(void) chatHistoryCreatedWithSuccess {
    [self.delegate chatHistoryCreatedWithSuccess];
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
                [self finishRecordingWithGestureIsValid:YES needsPause:NO];
                break;
            default:
                break;
        }
    } else if ([alertView.message isEqualToString:LOC(@"Time is up", @"Max time reached information message")]) {
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
        [self.delegate messageModel:event.sender isUpdatedWithStatus:model.sendingStatus cancelAble:isCacnelAble];
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

-(void) finishedRecordingWithSystemCancel {
    NSLog(@"finishedRecordingWithSystemCancel");
    [NSTimer scheduledTimerWithTimeInterval:LATENCY_TO_SYSTEM_CANCEL
                                     target:self
                                   selector:@selector(stopRecordingAccordingToSystemCancel)
                                   userInfo:nil
                                    repeats:NO];
}

-(void) stopRecordingAccordingToSystemCancel {
    [self finishRecordingWithGestureIsValid:NO needsPause:NO];
}

SUBSCRIBE(ApplicationWillResignActive) {
    if(!self.hidden) {
        [self backUpRecording];
    }
}

SUBSCRIBE(ApplicationDidBecomeActive) {
    if(!self.hidden) {
        weakself_create();
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(LATENCY_TO_RECOVER * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf handleAppIsActiveAgain];
        });
    }
}

-(void) backUpRecording {
    recordingViewStatus = RecordingViewStatusResignActive;
    [self.recordingModel backUpRecording];
    [[CacheModel sharedInstance] cacheOnDefaults:self.sendVoiceMessageModel];
}

-(void) handleAppIsActiveAgain {
    if(recordingViewStatus == RecordingViewStatusResignActive) {
        recordingViewStatus = RecordingViewStatusRecoverFromBackUp;
        CGFloat previousFileLength = [RecordingModel checkPreviousFileLength];
        BOOL isMessageLengthValid = previousFileLength > MIN_VOICE_MESSAGE_LENGTH;
        self.sendVoiceMessageModel = [[CacheModel sharedInstance] cachedSendVoiceMessageModelFromDefaults];
        
        if(!isMessageLengthValid || self.sendVoiceMessageModel == nil) {
            [RecordingModel setPreviousFileLength:0];
            [self dissmissWithFadeOut];
        } else {
            self.sendVoiceMessageModel.delegate = self;
            _recordingModel = nil;
            [self recordingModel];
            [self showAlertForRecordIsCut];
        }
    }
}

-(RecordingModel*) recordingModel {
    if(!_recordingModel) {
        _recordingModel = [GoogleSpeechRecordingModel new];
        _recordingModel.delegate = self;
    }
    return _recordingModel;
}

-(void) operationFailure:(NSError*) error {
    NSLog(@"an error occuren in recording view.");
    [self.delegate messageModel:self.sendVoiceMessageModel isUpdatedWithStatus:SendingStatusInited cancelAble:NO];
    [super operationFailure:error];
}

@end
