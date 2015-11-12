//
//  SendVoiceMessageModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 27/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "SendVoiceMessageModel.h"
#import "ConnectionModel.h"

#define TIMER_PERIOD    3

@implementation SendVoiceMessageModel {
    ConnectionModel *connectionModel;
    NSTimer *timer;
}

-(id) init {
    self = [super init];
    if(self) {
        recentContactsModel = [RecentContactsModel new];
        recentContactsModel.delegate = self;
        self.peppermintMessageSender = [PeppermintMessageSender savedSender];
        awsModel = [AWSModel new];
        awsModel.delegate = self;
        self.sendingStatus = SendingStatusIniting;
        [awsModel initRecorder];
        connectionModel = [ConnectionModel new];
        [connectionModel beginTracking];
        timer = nil;
    }
    return self;
}

-(void) dealloc {
    
    if(self.sendingStatus != SendingStatusCached
       && self.sendingStatus != SendingStatusCancelled
       && self.sendingStatus != SendingStatusError
       && self.sendingStatus != SendingStatusInited
       && self.sendingStatus != SendingStatusIniting
       && self.sendingStatus != SendingStatusSent
       ) {
        NSLog(@"Dealloc a sendVoiceMessageModel during %d state", (int)self.sendingStatus);
    }
    
    [connectionModel stopTracking];
    connectionModel = nil;
}

-(void) sendVoiceMessageWithData:(NSData*) data withExtension:(NSString*) extension {
    [recentContactsModel save:self.selectedPeppermintContact];
    [self attachProcessToAppDelegate];
    
#warning "Busy wait, think to make it with a more smart way"
    if(self.sendingStatus == SendingStatusIniting) {
        while (self.sendingStatus != SendingStatusInited ) {
            NSLog(@"waiting aws model to be ready!");
        }
    }
}

#pragma mark - RecentContactsModelDelegate

-(void) recentPeppermintContactSavedSucessfully:(PeppermintContact*) recentContact {
    [self.delegate newRecentContactisSaved];
}

-(void) operationFailure:(NSError*) error {
    self.sendingStatus = SendingStatusError;
    [self.delegate operationFailure:error];
}

#pragma mark - AWSModelDelegate
-(void) recorderInitIsSuccessful {
    self.sendingStatus = SendingStatusInited;
}

-(void) fileUploadCompletedWithPublicUrl:(NSString*) url {
    //NSLog(@"File Upload is finished with url %@", url);
}

#pragma mark - Type For Extension

-(NSString*) typeForExtension:(NSString*) extension {
    NSString *type = nil;
    if([extension isEqualToString:EXTENSION_M4A]) {
        type = TYPE_M4A;
    } else if ([extension isEqualToString:EXTENSION_AAC]) {
        type = TYPE_AAC;
    } else {
        NSAssert(false, @"MIME Type could not be read!");
    }
    return type;
}

SUBSCRIBE(NetworkFailure) {
    self.sendingStatus = SendingStatusError;
    [self.delegate operationFailure:[event error]];
}

-(BOOL) isServiceAvailable {
    return YES;
}

-(BOOL) needsAuth {
    return NO;
}

-(void) messagePrepareIsStarting {
    self.sendingStatus = SendingStatusStarting;
    [self.delegate messageStatusIsUpdated:SendingStatusStarting withCancelOption:YES];
}

-(void) cancelSending {
    NSLog(@"Cancelling!");
    awsModel.delegate = nil;
    awsModel = nil;
    recentContactsModel = nil;
    self.sendingStatus = SendingStatusCancelled;
}

-(BOOL) isCancelled {
    return self.sendingStatus == SendingStatusCancelled;
}

-(NSString*) fastReplyUrlForSender {
    NSString *urlPath = [NSString stringWithFormat:@"%@://%@?%@=%@&%@=%@",
                         SCHEME_PEPPERMINT,
                         HOST_FASTREPLY,
                         QUERY_COMPONENT_NAMESURNAME,
                         self.peppermintMessageSender.nameSurname,
                         QUERY_COMPONENT_EMAIL,
                         self.peppermintMessageSender.email
                         ];
    
    urlPath = [NSString stringWithFormat:@"https://%@.com/%@/user?%@=%@&%@=%@",
                         SCHEME_PEPPERMINT,
                         HOST_FASTREPLY,
                         QUERY_COMPONENT_NAMESURNAME,
                         self.peppermintMessageSender.nameSurname,
                         QUERY_COMPONENT_EMAIL,
                         self.peppermintMessageSender.email
                         ];
    
    NSString* encodedUrlPath = [urlPath stringByAddingPercentEscapesUsingEncoding:
                            NSUTF8StringEncoding];

    /*
#warning "Now using tinyUrl to compress the link. It should use an api on peppermint.com or Universal URL for this work"
    NSString *tinyUrlPath = [NSString stringWithFormat:@"https://tinyurl.com/api-create.php?url=%@", encodedUrlPath];
    NSURL *tinyUrl = [NSURL URLWithString:tinyUrlPath];
    NSError *error;
    NSString *compressedLink = [NSString stringWithContentsOfURL:tinyUrl encoding:NSUTF8StringEncoding error:&error];
    if(error) {
        encodedUrlPath = @"http://www.peppermint.com";
        [self.delegate operationFailure:error];
    } else {
        encodedUrlPath = compressedLink;
        
    }
    */
    
    
    return encodedUrlPath;
}

#pragma mark - Internet Connection

-(BOOL) isConnectionActive {
    return [connectionModel isInternetReachable];
}

#pragma mark - Attachment with AppDelegate

-(void) attachProcessToAppDelegate {
    NSMutableArray *array = [AppDelegate Instance].mutableArray;
    if(![array containsObject:self]) {
        NSLog(@"Attached and timer started!!");
        [array addObject:self];
        if(timer) { [timer invalidate]; NSLog(@"invalidated a timer!!"); }
        timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_PERIOD target:self selector:@selector(detachProcessFromAppDelegate) userInfo:nil repeats:YES];
        timer.tolerance = TIMER_PERIOD * 0.1;
        
    } else {
        NSLog(@"Attach is called on a pre-attached item");
    }
}

-(void) detachProcessFromAppDelegate {
    NSLog(@"Check for detach!");
    if(self.sendingStatus != SendingStatusStarting
       && self.sendingStatus != SendingStatusUploading
       && self.sendingStatus != SendingStatusSending
       ) {
        NSMutableArray *array = [AppDelegate Instance].mutableArray;
        if([array containsObject:self]) {
            [array removeObject:self];
            NSLog(@"Detached!!");
            [timer invalidate];
            timer = nil;
        } else {
            NSLog(@"Detach is called on a non-attached item");
        }
    }
}

#pragma mark - Active SendVoiceMessageModel

+(SendVoiceMessageModel*) activeSendVoiceMessageModel {
    SendVoiceMessageModel *sendVoiceMessageModel = nil;
    NSMutableArray *array = [AppDelegate Instance].mutableArray;
    for(SendVoiceMessageModel *item in array) {
        if(!sendVoiceMessageModel
           || sendVoiceMessageModel.sendingStatus > item.sendingStatus) {
            sendVoiceMessageModel = item;
        }
    }
    return sendVoiceMessageModel;
}
 
@end
