//
//  SendVoiceMessageMailClientModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 18/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "SendVoiceMessageMailClientModel.h"

@implementation SendVoiceMessageMailClientModel

-(void) sendVoiceMessageWithData:(NSData *)data withExtension:(NSString *)extension andDuration:(NSTimeInterval)duration {
    [super sendVoiceMessageWithData:data withExtension:extension andDuration:duration];
    if([self isConnectionActive]) {
        _data = data;
        _extension = extension;
        _duration = duration;
        self.sendingStatus = SendingStatusUploading;
        [awsModel startToUploadData:data ofType:[self typeForExtension:extension]];
    } else {
        [self cacheMessage];
    }
}

#pragma mark - AWSModelDelegate

-(void) fileUploadStartedWithPublicUrl:(NSString*) url canonicalUrl:(NSString*)canonicalUrl{
    [super fileUploadStartedWithPublicUrl:url canonicalUrl:canonicalUrl];
    if(![self isCancelled]) {
        _publicFileUrl = url;
        _canonicalUrl = canonicalUrl;
        self.sendingStatus = SendingStatusSending;
        self.sendingStatus = SendingStatusSendingWithNoCancelOption;
        [self tryInterAppMessage:canonicalUrl];
    } else {
        NSLog(@"Mandrill message sending is not fired, cos message is cancelled");
    }
}

-(BOOL) needsAuth {
    return YES;
}

-(void) cancelSending {
    _data = nil;
    _extension = nil;
    _duration = 0;
    [super cancelSending];
}

-(BOOL) isCancelAble {
    BOOL result = NO;
    switch (self.sendingStatus) {
        case SendingStatusIniting:
        case SendingStatusInited:
        case SendingStatusStarting:
        case SendingStatusUploading:
        case SendingStatusSending:
            result = YES;
            break;
        case SendingStatusError:
        case SendingStatusCancelled:
        case SendingStatusCached:
        case SendingStatusSendingWithNoCancelOption:
        case SendingStatusSent:
            result = NO;
            break;
        default:
            break;
    }
    return result;
}

@end
