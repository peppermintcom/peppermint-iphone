//
//  ChatEntryModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 24/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import "PeppermintChatEntry.h"

@protocol ChatEntryModelDelegate <BaseModelDelegate>
-(void) peppermintChatEntriesArrayIsUpdated;
-(void) peppermintChatEntrySavedWithSuccess:(NSArray*) savedPeppermintChatEnryArray;
@end

@interface ChatEntryModel : BaseModel
@property (weak, nonatomic) id<ChatEntryModelDelegate> delegate;
@property (strong, nonatomic) NSArray<PeppermintChatEntry*> *chatEntriesArray;

-(void) refreshPeppermintChatEntriesForContactEmail:(NSString*) contactEmail;
-(void) savePeppermintChatEntry:(PeppermintChatEntry*)peppermintChatEntry;
-(void) savePeppermintChatEntryArray:(NSArray*)peppermintChatEntryArray;
-(void) queryServerForIncomingMessages;

@end