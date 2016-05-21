//
//  SendVoiceMessageModelAddition.m
//  Peppermint
//
//  Created by Okan Kurtulus on 08/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "SendVoiceMessageModelAddition.h"

@implementation SendVoiceMessageModel (SendVoiceMessageModelAddition)

#pragma mark - Send Inter App Message

-(void) tryInterAppMessage:(NSString*) publicUrl {
    NSLog(@"Trying InterApp for file: %@", publicUrl);
    if( self.selectedPeppermintContact.communicationChannel != CommunicationChannelEmail ) {
        NSLog(@"App does not send message over SMS address yet");
    } else {
        [awsModel sendInterAppMessageTo:self.selectedPeppermintContact.communicationChannelAddress
                                   from:self.peppermintMessageSender.email
                   withTranscriptionUrl:@"https://qdkkavugcd.execute-api.us-west-2.amazonaws.com/prod/v1/transcriptions/mMuYhGEqnPg3H2M42YnvGB"
                               audioUrl:publicUrl];
    }
}

#pragma mark - AWSModelDelegate

-(void) sendInterAppMessageIsCompletedWithSuccess {
    NSLog(@"Inter App message is sent");
    self.sendingStatus = SendingStatusSent;
}

-(void) sendInterAppMessageIsCompletedWithError:(NSError*)error {
    NSLog(@"InterApp Message error, trying to send email");
}

-(void) sendInterAppMessageWasUnauthorised {
    NSLog(@"sendInterAppMessageWasUnauthorised");
    [self cacheMessage];
}

@end
