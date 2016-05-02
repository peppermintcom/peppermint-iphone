//
//  ChatEntryModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 24/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import "PeppermintChatEntry.h"
#import "PeppermintContactWithChatEntry.h"

@protocol ChatEntryModelDelegate <BaseModelDelegate>
-(void) peppermintChatEntriesArrayIsUpdated;
-(void) peppermintChatEntrySavedWithSuccess:(NSArray*) savedPeppermintChatEnryArray;
-(void) lastMessagesAreUpdated:(NSArray<PeppermintContactWithChatEntry*>*) peppermintContactWithChatEntryArray;
@end

@interface ChatEntryModel : BaseModel
@property (weak, nonatomic) id<ChatEntryModelDelegate> delegate;
@property (strong, atomic) NSArray<PeppermintChatEntry*> *chatEntriesArray;

-(void) refreshPeppermintChatEntriesForContactEmail:(NSString*) contactEmail;
-(void) savePeppermintChatEntry:(PeppermintChatEntry*)peppermintChatEntry;
-(void) savePeppermintChatEntryArray:(NSArray*)peppermintChatEntryArray;
-(void) deletePeppermintChatEntry:(PeppermintChatEntry*)peppermintChatEntry;
-(BOOL) isSyncProcessActive;
-(void) makeSyncRequestForMessages;
-(void) updateChatEntryWithAudio:(NSData*)audio toAudioUrl:(NSString*)audioUrl;
-(void) markAllPreviousMessagesAsRead:(PeppermintChatEntry*)peppermintChatEntry;
-(void) getLastMessagesForPeppermintContacts:(NSArray<PeppermintContact*>*)peppermintContactArray;
-(NSArray<PeppermintContactWithChatEntry*>*) filter:(NSArray<PeppermintContactWithChatEntry*>*)peppermintContactWithChatEntryArray withFilter:(NSString*) filterText;

#pragma mark - Chat Helper Functions
+(NSPredicate*) unreadAudioMessagesPredicateForEmail:(NSString*) email;
-(NSUInteger) unreadMessageCountOfAllChats;
+(NSSet*) receivedMessagesEmailSet;


@end
