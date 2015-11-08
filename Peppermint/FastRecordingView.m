//
//  FastRecordingView.m
//  Peppermint
//
//  Created by Okan Kurtulus on 15/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "FastRecordingView.h"
#import "ExplodingView.h"
#import "SendVoiceMessageMandrillModel.h"

typedef enum : NSUInteger {
    FastRecordingViewStatusResignActive,
    FastRecordingViewStatusRecoverFromBackUp,
    FastRecordingViewStatusPresented,
    FastRecordingViewStatusInit,
    FastRecordingViewStatusFinishing,
} FastRecordingViewStatus;

@implementation FastRecordingView {
    FastRecordingViewStatus fastRecordingViewStatus;
}

+(FastRecordingView*) createInstanceWithDelegate:(UIViewController<FastRecordingViewDelegate>*) delegate {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FastRecordingView"
                                                             owner:self
                                                           options:nil];
    FastRecordingView *fastRecordingView = (FastRecordingView *)[topLevelObjects objectAtIndex:0];
    fastRecordingView.delegate = delegate;
    [fastRecordingView timerUpdated:0];
    fastRecordingView.playingModel = [PlayingModel new];
    return fastRecordingView;
}

- (void)awakeFromNib {
    self.navigationTitleLabel.font = [UIFont openSansSemiBoldFontOfSize:24];
    self.navigationTitleLabel.textColor = [UIColor whiteColor];
    self.counterLabel.font = [UIFont openSansSemiBoldFontOfSize:40];
    self.counterLabel.textColor = [UIColor whiteColor];
    
    self.progressContainerView.backgroundColor = [UIColor progressContainerViewGray];
    self.progressContainerView.layer.cornerRadius = 35;
    [self.m13ProgressViewPie setPrimaryColor:[UIColor progressCoverViewGreen]];
    [self.m13ProgressViewPie setSecondaryColor:[UIColor clearColor]];
    self.hidden = YES;
    defaults_set_object(DEFAULTS_KEY_PREVIOUS_RECORDING_LENGTH, 0);
    self.swipeInAnyDirectionLabel.text = LOC(@"Swipe in any direction to cancel", @"Swipe in any direction label");
    REGISTER();
    
    self.backgroundView.alpha = 0.95;
    //[self initBlurView];
    fastRecordingViewStatus = FastRecordingViewStatusInit;
}

/*
-(void) initBlurView {
    self.backgroundColor = [UIColor clearColor];
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.backgroundView.alpha = 1;
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        
        blurEffectView.frame = self.backgroundView.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.backgroundView addSubview:blurEffectView];
    }
    else {
        self.backgroundView.backgroundColor = [UIColor blackColor];
        self.backgroundView.alpha = 0.9;
    }
}
*/

-(void) prepareViewToPresent {
    self.navigationTitleLabel.text = [NSString stringWithFormat:
                                      LOC(@"Recording for contact format", @"Title Text Format"),
                                      self.sendVoiceMessageModel.selectedPeppermintContact.nameSurname,
                                      self.sendVoiceMessageModel.selectedPeppermintContact.communicationChannelAddress
                                      ];
    self.sendVoiceMessageModel.delegate = self;
    self.recordingModel = [RecordingModel new];
    self.recordingModel.delegate = self;
    self.progressContainerView.hidden = NO;
}

#pragma mark - Record Methods
-(void) presentWithAnimation {
    if(fastRecordingViewStatus == FastRecordingViewStatusInit) {
        fastRecordingViewStatus = FastRecordingViewStatusPresented;
        self.counterLabel.text = @"";
        self.alpha = 0;
        self.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 1;
        }];
        assert(self.sendVoiceMessageModel != nil);
        [self prepareViewToPresent];
    }
}

-(void) finishRecordingWithGestureIsValid:(BOOL) isGestureValid {
    if(fastRecordingViewStatus == FastRecordingViewStatusPresented) {
        fastRecordingViewStatus = FastRecordingViewStatusFinishing;
        
        [self.recordingModel stop];
        
        BOOL isRecordingLong = self.totalSeconds >= MAX_RECORD_TIME;
        BOOL isRecordingShort = self.totalSeconds <= MIN_VOICE_MESSAGE_LENGTH;
        BOOL isLoginInfoValid = self.sendVoiceMessageModel.peppermintMessageSender.isValid;
        
        if(!isGestureValid) {
            [self dissmissWithExplode];
        } else if (isRecordingLong) {
            NSLog(@"Max time reached..."); //This action is handled in "timerUpdated:" delegate method
        } else if (isRecordingShort) {
            [self showAlertToRecordMoreThanMinimumMessageLength];
        } else if ([self.sendVoiceMessageModel needsAuth] && !isLoginInfoValid ) {
            [LoginNavigationViewController logUserInWithDelegate:self completion:nil];
        } else {
            [self dissmissWithFadeOut];
            [self performOperationsToSend];
        }
    } else {
        NSLog(@"FastRecordingView is not presented!");
    }
}

-(void) performOperationsToSend {
    [self.sendVoiceMessageModel messagePrepareIsStarting];
    [self.recordingModel prepareRecordData];
}

-(void) cancelMessageSending {
    [self.sendVoiceMessageModel cancelSending];
}

#pragma mark - Dissmiss

-(void) dissmissWithFadeOut {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL completed) {
        self.hidden = YES;
        self.alpha = 1;
        [self timerUpdated:0];
        fastRecordingViewStatus = FastRecordingViewStatusInit;
        [self.delegate fastRecordingViewDissappeared];
    }];
}

-(void) dissmissWithExplode {
    
    ExplodingView *explodingView = [ExplodingView createInstanceFromView:self.progressContainerView];
    [self.superview addSubview:explodingView];
    [self.superview bringSubviewToFront:explodingView];
    self.progressContainerView.hidden = YES;
    [explodingView lp_explodeWithCallback:^{
        [self dissmissWithFadeOut];
    }];
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
    if(fastRecordingViewStatus == FastRecordingViewStatusPresented) {
        [self.recordingModel resetRecording];
        if([RecordingModel checkPreviousFileLength] < MIN_VOICE_MESSAGE_LENGTH) {
            [self.playingModel playBeginRecording];
            [self beginRecording];
        } else {
            NSLog(@"Önceden kalan kayıt var sanırım!");
            [self showAlertForRecordIsCut];
        }
    } else {
        NSLog(@"Fastrecording view is not in presented state! Will not show!");
    }
}

-(void) timerUpdated:(NSTimeInterval) timeInterval {
    self.totalSeconds = timeInterval;
    if(self.totalSeconds <= MAX_RECORD_TIME + 0.3) {
        int minutes = self.totalSeconds / 60;
        int seconds = ((int)self.totalSeconds) % 60;
        self.counterLabel.text = [NSString stringWithFormat:@"%.1d:%.2d", minutes, seconds];
        [self.m13ProgressViewPie setProgress:timeInterval/MAX_RECORD_TIME animated:YES];
    } else {
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
    [self.sendVoiceMessageModel sendVoiceMessageWithData:data withExtension: extension];
}

#pragma mark - SendVoiceMessage Delegate

-(void) messageStatusIsUpdated:(SendingStatus) sendingStatus withCancelOption:(BOOL) cancelable {
    [self.delegate messageStatusIsUpdated:sendingStatus withCancelOption:cancelable];
}

#pragma mark - LoginNavigationViewControllerDelegate

-(void) loginSucceedWithMessageSender:(PeppermintMessageSender*) peppermintMessageSender {
    NSLog(@"login %@ - %@", peppermintMessageSender.nameSurname, peppermintMessageSender.email);
    [self dissmissWithFadeOut];
    [self performOperationsToSend];
}


#pragma mark - AlertView Delegate

-(void) showAlertToRecordMoreThanMinimumMessageLength {
    MBProgressHUD * hud =  [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelFont = [UIFont openSansFontOfSize:12];
    hud.detailsLabelText = [NSString stringWithFormat:LOC(@"Record More Than Limit Format", @"Format of minimum recording warning text"),
                            MIN_VOICE_MESSAGE_LENGTH];
    hud.removeFromSuperViewOnHide = YES;
    hud.yOffset += (self.frame.size.height * 0.3);
    
    [hud hide:YES afterDelay:WARN_TIME];
    dispatch_time_t hideTime = dispatch_time(DISPATCH_TIME_NOW, WARN_TIME * 1.2 * NSEC_PER_SEC);
    dispatch_after(hideTime, dispatch_get_main_queue(), ^(void){
        [self dissmissWithFadeOut];
    });
}

-(void) showAlertToCompleteLoginInformation {
    NSString *title = LOC(@"Information", @"Title Message");
    NSString *message = LOC(@"Account details message", @"Account details message") ;
    NSString *cancelButtonTitle = LOC(@"Cancel", @"Cancel Message");
    NSString *okButtonTitle = LOC(@"Ok", @"Ok Message");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:okButtonTitle, nil];
    alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    UITextField *nameSurnameTextField = [alertView textFieldAtIndex:0];
    nameSurnameTextField.secureTextEntry = NO;
    nameSurnameTextField.placeholder = LOC(@"Name surname", @"Name surname");
    nameSurnameTextField.keyboardType = UIKeyboardTypeAlphabet;
    nameSurnameTextField.text = self.sendVoiceMessageModel.peppermintMessageSender.nameSurname;
    UITextField *emailTextField = [alertView textFieldAtIndex:1];
    emailTextField.secureTextEntry = NO;
    emailTextField.placeholder = LOC(@"Email", @"Email");
    emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    emailTextField.text = self.sendVoiceMessageModel.peppermintMessageSender.email;
    [alertView show];
}

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
    }
    else if ([alertView.message isEqualToString:LOC(@"Recording is cut", @"Recording is cut, how to continue question?")]) {
        switch (buttonIndex) {
            case ALERT_BUTTON_INDEX_CANCEL:
                [RecordingModel setPreviousFileLength:0];
                [self dissmissWithFadeOut];
                //__clear backup files
                break;
            case ALERT_BUTTON_INDEX_OTHER_1:
                [self.recordingModel record];
                fastRecordingViewStatus = FastRecordingViewStatusPresented;
                [self finishRecordingWithGestureIsValid:YES];
                break;
            default:
                break;
        }
    }
    else if ([alertView.message isEqualToString:LOC(@"Time is up", @"Max time reached information message")]) {
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
    }
    else if ([alertView.message isEqualToString:LOC(@"Account details message", @"Account details message")]) {
        UITextField *nameSurnameTextField = [alertView textFieldAtIndex:0];
        UITextField *emailTextField = [alertView textFieldAtIndex:1];
        PeppermintMessageSender *peppermintMessageSender = self.sendVoiceMessageModel.peppermintMessageSender;
        switch (buttonIndex) {
            case ALERT_BUTTON_INDEX_OTHER_1:
                peppermintMessageSender.nameSurname = nameSurnameTextField.text;
                peppermintMessageSender.email = emailTextField.text;
                
                if(!peppermintMessageSender.isValid) {
                    [self showAlertToCompleteLoginInformation];
                } else {
                    [peppermintMessageSender save];
                    [self dissmissWithFadeOut];
                    [self performOperationsToSend];
                }
                break;
            default:
                [self dissmissWithFadeOut];
                break;
        }
    }
    else {
        NSLog(@"Unhandled alertview Message: %@", alertView.message);
    }
}

#pragma mark - Record Actions

-(void) beginRecording {
    [self.recordingModel stop];
    [self.recordingModel record];
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
    NSLog(@"ApplicationWillResignActive");
    fastRecordingViewStatus = FastRecordingViewStatusResignActive;
    [self.recordingModel backUpRecording];
}

SUBSCRIBE(ApplicationDidBecomeActive) {
    [self handleAppIsActiveAgain];
}

-(void) handleAppIsActiveAgain {
    if(fastRecordingViewStatus == FastRecordingViewStatusResignActive) {
        fastRecordingViewStatus = FastRecordingViewStatusRecoverFromBackUp;
        NSLog(@"ApplicationDidBecomeActive");
        CGFloat previousFileLength = [RecordingModel checkPreviousFileLength];
        if( previousFileLength > MIN_VOICE_MESSAGE_LENGTH) {
            if(!self.sendVoiceMessageModel) {
                NSError *error = [NSError errorWithDomain:@"sendVoiceMessageModel was released. This message can not be sent! :(" code:-1 userInfo:nil];
                [self.delegate operationFailure:error];
            }
            self.sendVoiceMessageModel.delegate = self;
            
            if(!self.recordingModel) {
                self.recordingModel = [RecordingModel new];
                self.recordingModel.delegate = self;
            } else {
                self.recordingModel.delegate = self;
                [self showAlertForRecordIsCut];
            }
        } else {
            [RecordingModel setPreviousFileLength:0];
            [self dissmissWithFadeOut];
        }
    }
}

@end
