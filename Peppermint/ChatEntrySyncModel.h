//
//  ChatEntrySyncModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 02/05/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import "ChatEntryModel.h"
#import "RecentContactsModel.h"

@class SyncDateHolder;

@protocol ChatEntrySyncModelDelegate <BaseModelDelegate>
-(void) syncStepCompleted:(NSArray<PeppermintChatEntry*>*) syncedPeppermintChatEnryArray isLastStep:(BOOL)isCompleted;
@end

@interface ChatEntrySyncModel : BaseModel <ChatEntryModelDelegate, RecentContactsModelDelegate>

@property (weak, nonatomic) id<ChatEntrySyncModelDelegate> delegate;
@property (strong, nonatomic) RecentContactsModel *recentContactsModel;
@property (strong, nonatomic) ChatEntryModel *chatEntryModel;
@property (strong, nonatomic) SyncDateHolder *syncDateHolder;

+ (instancetype) sharedInstance;
-(BOOL) isSyncProcessActive;
-(void) makeSyncRequestForMessages;

-(BOOL) isReciviedMessagesAreInSyncOfFirstCycle;
-(BOOL) issentMessagesAreInSyncOfFirstCycle;
-(BOOL) isAllMessagesAreInSyncOfFirstCycle;

@end
