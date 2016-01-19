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


-(NSString*) mailBodyHTMLForUrlPath:(NSString*)urlPath extension:(NSString*)extension signature:(NSString*) signature duration:(NSTimeInterval) duration {
    
    int minutes = duration / 60;
    int seconds = (int)duration % 60;
    
    int minutesDigit1 = minutes / 10;
    int minutesDigit2 = minutes % 10;
    int secondsDigit1 = seconds / 10;
    int secondsDigit2 = seconds % 10;
    
    NSString *replyLink = [self fastReplyUrlForSender];
    NSString *mailFormat = LOC(@"Mail Body Format",@"Default Mail Body Format");
    //NSString *type = [self typeForExtension:extension];
    
    return [NSString stringWithFormat:mailFormat
            ,urlPath
            ,minutesDigit1
            ,minutesDigit2
            ,secondsDigit1
            ,secondsDigit2
            ,replyLink
            ];
}

@end
