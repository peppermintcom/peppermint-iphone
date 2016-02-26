//
//  ChatEntryModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 24/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import "PeppermintChatEntry.h"
@class PeppermintContact;

@protocol ChatEntryModelDelegate <BaseModelDelegate>
-(void) chatEntriesArrayIsUpdated;
-(void) chatHistoryCreatedWithSuccess;
-(void) peppermintChatEntrySavedWithSuccess:(PeppermintChatEntry*)peppermintChatEntry;
@end

@interface ChatEntryModel : BaseModel
@property (weak, nonatomic) id<ChatEntryModelDelegate> delegate;
@property (strong, nonatomic) NSArray<PeppermintChatEntry*> *chatEntriesArray;

-(void) refreshChatEntriesForContactEmail:(NSString*) contactEmail;
-(void) update:(PeppermintChatEntry *) peppermintChatEntry;
-(void) createChatHistory:(PeppermintChatEntry*)peppermintChatEntry forPeppermintContact:(PeppermintContact*)peppermintContact;

@end
