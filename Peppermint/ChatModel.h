//
//  ChatModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 22/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"

@interface ChatModel : BaseModel

+(NSPredicate*) contactEmailPredicate:(NSString*) email;
+(NSPredicate*) unreadMessagesPredicateForEmail:(NSString*) email;
+(NSUInteger) unreadMessageCountOfAllChats;
+(NSSet*) receivedMessagesEmailSet;
+(NSArray*) unreadMessagesFromArray:(NSArray*) peppermintChatEntryArray;

@end
