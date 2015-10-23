//
//  FastRecordingView.m
//  Peppermint
//
//  Created by Okan Kurtulus on 15/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "FastRecordingView.h"
#import <AudioToolbox/AudioServices.h>
#import "ExplodingView.h"

@implementation FastRecordingView {

}

+(FastRecordingView*) createInstanceWithDelegate:(UIViewController<FastRecordingViewDelegate>*) delegate {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FastRecordingView"
                                                             owner:self
                                                           options:nil];
    FastRecordingView *fastRecordingView = (FastRecordingView *)[topLevelObjects objectAtIndex:0];
    fastRecordingView.delegate = delegate;
    [fastRecordingView timerUpdated:0];
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
}

-(RecordingModel*) getRecordingModel {
    if(!self.recordingModel) {
        self.recordingModel = [RecordingModel new];
    }
    return self.recordingModel;
}

-(void) initViewComponents {
    self.navigationTitleLabel.text = [NSString stringWithFormat:
                                      LOC(@"Recording for contact format", @"Title Text Format"),
                                      self.sendVoiceMessageModel.selectedPeppermintContact.nameSurname,
                                      self.sendVoiceMessageModel.selectedPeppermintContact.communicationChannelAddress
                                      ];
    self.sendVoiceMessageModel.delegate = self;
    
    self.recordingModel = [RecordingModel new];
    self.recordingModel.previousFileLength = 0;
    
    defaults_set_object(DEFAULTS_KEY_PREVIOUS_RECORDING_LENGTH, 0);
    self.recordingModel.delegate = self;
    self.progressContainerView.hidden = NO;
    #warning "Add app will resign notifications"
}

#pragma mark - Record Methods
-(void) presentWithAnimation {    
    self.alpha = 0;
    self.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
    }];
    assert(self.sendVoiceMessageModel != nil);
    [self initViewComponents];
}

-(void) finishRecordingWithGestureIsValid:(BOOL) isGestureValid {
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
    } else if (!isLoginInfoValid || isLoginInfoValid) {
#warning "Remove ' || isLoginInfoValid' from above "
        [self showAlertToCompleteLoginInformation];
    } else {
        [self dissmissWithFadeOut];
        [self performOperationsToSend];
    }
}

-(void) performOperationsToSend {
    [self.recordingModel prepareRecordData];
}

#pragma mark - Dissmiss

-(void) dissmissWithFadeOut {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL completed) {
        self.hidden = YES;
        self.alpha = 1;
        [self timerUpdated:0];
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
    if(self.recordingModel.previousFileLength == 0) {
        [self beginRecording];
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

- (void) recordDataIsPrepared:(NSData *)data {
    [self.sendVoiceMessageModel sendVoiceMessageWithData:data];
}

#pragma mark - SendVoiceMessage Delegate

-(void) messageIsSending {
    [self.delegate messageIsSending];
}

-(void) messageSentWithSuccess {
    [self.delegate messageSentWithSuccess];
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
#warning "include recording is cut"
    }
    else if ([alertView.message isEqualToString:LOC(@"Recording is cut", @"Recording is cut, how to continue question?")]) {
        switch (buttonIndex) {
            case ALERT_BUTTON_INDEX_CANCEL:
                [self.recordingModel resetRecording];
                break;
            case ALERT_BUTTON_INDEX_OTHER_1:
                break;
            default:
                break;
        }
        [self.recordingModel record];
    }
    else if ([alertView.message isEqualToString:LOC(@"Time is up", @"Max time reached information message")]) {
        switch (buttonIndex) {
            case ALERT_BUTTON_INDEX_CANCEL:
                [self dissmissWithExplode];
                break;
            case ALERT_BUTTON_INDEX_OTHER_1:
                [self finishRecordingWithGestureIsValid:YES];
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

@end
