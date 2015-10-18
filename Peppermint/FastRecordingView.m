//
//  FastRecordingView.m
//  Peppermint
//
//  Created by Okan Kurtulus on 15/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "FastRecordingView.h"
#import <AudioToolbox/AudioServices.h>

@implementation FastRecordingView {

}

+(FastRecordingView*) createInstanceWithDelegate:(UIViewController<FastRecordingViewDelegate>*) delegate {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FastRecordingView"
                                                             owner:self
                                                           options:nil];
    FastRecordingView *fastRecordingView = (FastRecordingView *)[topLevelObjects objectAtIndex:0];
    fastRecordingView.delegate = delegate;
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

-(void) initViewComponents {
    self.navigationTitleLabel.text = [NSString stringWithFormat:
                                      LOC(@"Recording for contact format", @"Title Text Format"),
                                      self.sendVoiceMessageModel.selectedPeppermintContact.nameSurname,
                                      self.sendVoiceMessageModel.selectedPeppermintContact.communicationChannelAddress
                                      ];
    self.sendVoiceMessageModel.delegate = self;
    
    self.recordingModel = [RecordingModel new];
    self.recordingModel.previousFileLength = 0;
    self.recordingModel.delegate = self;
    #warning "Add app will resign notifications"
}

#pragma mark - Record Methods
-(void) presentWithAnimation {
    CGRect frame = CGRectMake(0 , self.superview.frame.size.height, 1, 1);
    self.frame = frame;
    self.alpha = 0;
    self.hidden = NO;
    [UIView animateWithDuration:0.1 animations:^{
        self.frame = self.superview.frame;
        self.alpha = 1;
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        assert(self.sendVoiceMessageModel != nil);
        [self initViewComponents];
        if(self.recordingModel.grantedForMicrophone) {
            [self beginRecording];
        }
    });
}

-(void) finishRecordingWithSendMessage:(BOOL) sendMessage {
    [self dissmiss];
    if(sendMessage) {
        [self.recordingModel prepareRecordData];
    }
}

-(void) dissmiss {
    [self.recordingModel stop];
    self.hidden = YES;
    [self timerUpdated:0];
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
    int totalSeconds = (int)timeInterval;    
    if(totalSeconds < MAX_RECORD_TIME) {
        /*
        if(totalSeconds/5 % 2 == 0 ) {
            self.progressCenterImageView.image = [UIImage imageNamed:@"recording_logo1"];
        } else {
            self.progressCenterImageView.image = [UIImage imageNamed:@"recording_logo_right"];
        }
         */
        int minutes = totalSeconds / 60;
        int seconds = totalSeconds % 60;
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
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
}

- (void) recordDataIsPrepared:(NSData *)data {
    NSLog(@"Sending the message");
    [self dissmiss];
    
    
    [self.sendVoiceMessageModel sendVoiceMessageWithData:data overViewController:self.delegate];
}

#pragma mark - SendVoiceMessage Delegate

-(void) messageSentWithSuccess {
    NSLog(@"The message is sent");
    [self.delegate messageSentWithSuccess];
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if([alertView.message isEqualToString: LOC(@"Mic Access rights explanation", @"Directives to give access rights")]) {
        switch (buttonIndex) {
            case ALERT_BUTTON_INDEX_CANCEL:
                [self dissmiss];
                break;
            case ALERT_BUTTON_INDEX_OTHER_1:
                [self redirectToSettingsPageForPermission];
                break;
            default:
                break;
        }
    } else if([alertView.message isEqualToString:LOC(@"Message sent with success", @"Message sent information")]) {
        [self dissmiss];
    } else if ([alertView.message isEqualToString:LOC(@"Recording is cut", @"Recording is cut, how to continue question?")]) {
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
    } else if ([alertView.message isEqualToString:LOC(@"Time is up", @"Max time reached information message")]) {
        [self dissmiss];
    } else {
        NSLog(@"Unhandled alertview Message: %@", alertView.message);
    }
}

#pragma mark - Record Actions

-(void) beginRecording {
    [self timerUpdated:0];
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
