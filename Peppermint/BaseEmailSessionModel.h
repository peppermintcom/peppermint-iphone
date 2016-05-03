//
//  BaseEmailSessionModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 24/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import <MailCore/MailCore.h>
#import "PeppermintChatEntry.h"

@protocol BaseEmailSessionModelDelegate <BaseModelDelegate>
-(void) receivedMessage:(PeppermintChatEntry*)peppermintChatEntry;
@end

@interface BaseEmailSessionModel : BaseModel {
    __block BOOL canIdle;
    MCOIMAPSession *_session;
}

@property (weak, nonatomic) id<BaseEmailSessionModelDelegate> delegate;
@property (strong, nonatomic) NSString *folderInbox;
@property (strong, nonatomic) NSString *folderSent;

-(void) setLoggerActive:(BOOL) active;
-(MCOIMAPSession*) session;
-(void) initSession;
-(void) stopSession;

-(void) startToListenInbox;

@end
