//
//  SendVoiceMessageEmailModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 06/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "SendVoiceMessageEmailModel.h"

@implementation SendVoiceMessageEmailModel

#pragma mark - MailBody

-(NSString*) mailBodyHTMLForUrlPath:(NSString*)urlPath extension:(NSString*)extension signature:(NSString*) signature {
    
    NSString *mailFormat = LOC(@"Mail Body Format",@"Default Mail Body Format");
    NSString *type = [self typeForExtension:extension];
    NSString *replyLink = [self fastReplyUrlForSender];
    return [NSString stringWithFormat:mailFormat
            ,urlPath
            //,type
            ,replyLink
            //,signature
            ];
}

@end
