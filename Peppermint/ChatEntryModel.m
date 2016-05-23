//
//  ChatEntryModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 24/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatEntryModel.h"
#import "Repository.h"
#import "PeppermintChatEntry.h"
#import "PeppermintMessageSender.h"
#import "AWSService.h"
#import "RecentContactsModel.h"
#import "ContactsModel.h"
#import "CustomContactModel.h"
#import "ConnectionModel.h"

#define PREDICATE_UNREAD_MESSAGES [NSPredicate predicateWithFormat:@"self.isSeen = %@",@NO]

@implementation ChatEntryModel {
    AWSService *awsService;
}

-(id) init {
    self = [super init];
    if(self) {
        self.chatEntriesArray = [NSArray new];
        awsService = [AWSService new];
    }
    return self;
}

-(void) refreshPeppermintChatEntriesForContactEmail:(NSString*) contactEmail {
    weakself_create();
    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        NSPredicate *chatPredicate = [ChatEntryModel contactEmailPredicate:contactEmail];
        Repository *repository = [Repository beginTransaction];
        NSArray *chatEntryArray = [repository getResultsFromEntity:[ChatEntry class]
                                                    predicateOrNil:chatPredicate
                                                ascSortStringOrNil:[NSArray arrayWithObjects:@"dateCreated", nil]
                                               descSortStringOrNil:[NSArray arrayWithObjects:@"isSentByMe",  nil]];
        
        NSMutableArray *peppermintChatEntryArray = [NSMutableArray new];
        for(ChatEntry* chatEntry in chatEntryArray) {
            PeppermintChatEntry *peppermintChatEntry = [weakSelf peppermintChatEntryWith:chatEntry];
            if(peppermintChatEntry) {
                [peppermintChatEntryArray addObject:peppermintChatEntry];
            }
        }
        weakSelf.chatEntriesArray = peppermintChatEntryArray;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(weakSelf && [weakSelf.delegate respondsToSelector:@selector(peppermintChatEntriesArrayIsUpdated)]) {
                [weakSelf.delegate peppermintChatEntriesArrayIsUpdated];
            } else {
                NSLog(@"Delegate did not implement function peppermintChatEntriesArrayIsUpdated");
            }
        });
    });
}

-(PeppermintChatEntry*) peppermintChatEntryWith:(ChatEntry*)chatEntry {
    PeppermintChatEntry *peppermintChatEntry = [PeppermintChatEntry new];
    peppermintChatEntry.audio = chatEntry.audio;
    peppermintChatEntry.audioUrl = chatEntry.audioUrl;
    peppermintChatEntry.dateCreated = chatEntry.dateCreated;
    peppermintChatEntry.contactEmail = chatEntry.contactEmail;
    peppermintChatEntry.duration = chatEntry.duration.integerValue;
    peppermintChatEntry.isSeen = chatEntry.isSeen.boolValue;
    peppermintChatEntry.isSentByMe = chatEntry.isSentByMe.boolValue;
    peppermintChatEntry.messageId = chatEntry.messageId;
    peppermintChatEntry.subject = chatEntry.subject;
    peppermintChatEntry.mailContent = chatEntry.mailContent;
    peppermintChatEntry.isRepliedAnswered = chatEntry.isRepliedAnswered.boolValue;
    peppermintChatEntry.isStarredFlagged = chatEntry.isStarredFlagged.boolValue;
    peppermintChatEntry.isForwarded = chatEntry.isForwarded.boolValue;
    peppermintChatEntry.transcription = chatEntry.transcription;
    return peppermintChatEntry;
}

#pragma mark - Save

-(void) savePeppermintChatEntry:(PeppermintChatEntry*)peppermintChatEntry {
    [self savePeppermintChatEntryArray:[NSArray arrayWithObject:peppermintChatEntry]];
}

-(void) savePeppermintChatEntryArray:(NSArray*)peppermintChatEntryArray {
    weakself_create();
    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        Repository *repository = [Repository beginTransaction];
        for(PeppermintChatEntry *peppermintChatEntry in peppermintChatEntryArray) {
            ChatEntry *chatEntry = nil;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                      @"((self.messageId == nil OR self.messageId == %@) \
                                      AND (self.audioUrl == nil OR self.audioUrl == %@) \
                                      AND (self.isSentByMe == %d))"
                                      , peppermintChatEntry.messageId
                                      , peppermintChatEntry.audioUrl
                                      , peppermintChatEntry.isSentByMe
                                      ];
            
            NSPredicate *emailPredicate = [ChatEntryModel contactEmailPredicate:peppermintChatEntry.contactEmail];
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:
                                                                            predicate,
                                                                            emailPredicate,
                                                                            nil]];
            
            NSArray *existingChatEntriesArray = [repository getResultsFromEntity:[ChatEntry class] predicateOrNil:predicate];
            
            if(!existingChatEntriesArray || existingChatEntriesArray.count == 0) {
                chatEntry = (ChatEntry*)[repository createEntity:[ChatEntry class]];
                peppermintChatEntry.performedOperation = PerformedOperationCreated;
            } else if(existingChatEntriesArray.count == 1) {
                chatEntry = existingChatEntriesArray.firstObject;
                [weakSelf checkChatEntry:chatEntry andMarkAsReadIfNeededWithPeppermintChatEntry:peppermintChatEntry];
                peppermintChatEntry.performedOperation = PerformedOperationUpdated;
            } else if(peppermintChatEntry.messageId != nil) {
                chatEntry = [existingChatEntriesArray objectAtIndex:0];
                int i=0;
                for(ChatEntry *chatEntry in existingChatEntriesArray) {
                    NSLog(@"%d.M:%@, A:%@, s:%@, c:%@", ++i, chatEntry.messageId, chatEntry.audioUrl, chatEntry.isSentByMe, chatEntry.contactEmail);
                }
                NSLog(@"More than 1 unique chatEntry record is active as seen above...");
            } else {
                exception(@"This case should not happen!");
            }
            
            chatEntry.messageId = peppermintChatEntry.messageId;
            chatEntry.contactEmail = peppermintChatEntry.contactEmail;
            chatEntry.audio = peppermintChatEntry.audio ? peppermintChatEntry.audio : chatEntry.audio;
            chatEntry.audioUrl = peppermintChatEntry.audioUrl;
            chatEntry.transcription = peppermintChatEntry.transcription ? peppermintChatEntry.transcription : chatEntry.transcription;
            chatEntry.isSentByMe = [NSNumber numberWithBool:peppermintChatEntry.isSentByMe];
            chatEntry.dateCreated = peppermintChatEntry.dateCreated;
            chatEntry.isSeen = [NSNumber numberWithBool:
                                chatEntry.isSeen.boolValue
                                || peppermintChatEntry.isSeen
                                || (peppermintChatEntry.audio && peppermintChatEntry.isSentByMe)];
            chatEntry.duration = [NSNumber numberWithDouble:peppermintChatEntry.duration];
            chatEntry.subject = peppermintChatEntry.subject;
            chatEntry.mailContent = peppermintChatEntry.mailContent;
            chatEntry.isRepliedAnswered = [NSNumber numberWithBool:peppermintChatEntry.isRepliedAnswered];
            chatEntry.isStarredFlagged = [NSNumber numberWithBool:peppermintChatEntry.isStarredFlagged];
            chatEntry.isForwarded = [NSNumber numberWithBool:peppermintChatEntry.isForwarded];
        }
        
        NSError *error = [repository endTransaction];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error) {
                [weakSelf.delegate operationFailure:error];
            } else {
                [weakSelf.delegate peppermintChatEntrySavedWithSuccess:peppermintChatEntryArray];
            }
        });
    });
}

#pragma mark - Delete

-(void) deletePeppermintChatEntry:(PeppermintChatEntry*)peppermintChatEntry {
    weakself_create();
    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        Repository *repository = [Repository beginTransaction];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"((self.messageId == %@) \
                                  AND (self.audioUrl == %@) \
                                  AND (self.isSentByMe == %d))"
                                  , peppermintChatEntry.messageId
                                  , peppermintChatEntry.audioUrl
                                  , peppermintChatEntry.isSentByMe
                                  ];
        
        NSPredicate *emailPredicate = [ChatEntryModel contactEmailPredicate:peppermintChatEntry.contactEmail];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:
                                                                        predicate,
                                                                        emailPredicate,
                                                                        nil]];
        
        NSArray *existingChatEntriesArray = [repository getResultsFromEntity:[ChatEntry class] predicateOrNil:predicate];
        if(existingChatEntriesArray.count == 0) {
            NSLog(@"Could not find any matching chatEntries. Will not delete any record.");
        } else {
            NSLog(@"Deleting %ld matching chatEntry(ies)", (unsigned long)existingChatEntriesArray.count);
            for(ChatEntry *chatEntry in existingChatEntriesArray) {
                [repository deleteEntity:chatEntry];
            }
        }
        
        NSError *error = [repository endTransaction];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error) {
                [weakSelf.delegate operationFailure:error];
            } else {
                NSLog(@"Delete process is completed without errors.");
            }
        });
    });
}


#pragma mark - Mark As Read

-(void) checkChatEntry:(ChatEntry*)chatEntry andMarkAsReadIfNeededWithPeppermintChatEntry:(PeppermintChatEntry*)peppermintChatEntry {
    if(!chatEntry.isSeen.boolValue
       && peppermintChatEntry.isSeen
       && peppermintChatEntry.messageId.length > 0
       && peppermintChatEntry.type == ChatEntryTypeAudio) {
        PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
        [awsService markMessageAsReadWithJwt:peppermintMessageSender.exchangedJwt messageId:peppermintChatEntry.messageId];
    }
}

#pragma mark - Update AudioUrl

-(void) updateChatEntryWithAudio:(NSData*)audio toAudioUrl:(NSString*)audioUrl {
    weakself_create();
    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        Repository *repository = [Repository beginTransaction];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.audio == %@ AND self.isSentByMe == %d", audio, YES];
        NSArray *matchingChatEntries = [repository getResultsFromEntity:[ChatEntry class] predicateOrNil:predicate];
        if(matchingChatEntries.count == 1) {
            ChatEntry *chatEntry = matchingChatEntries.firstObject;
            chatEntry.audioUrl = audioUrl;
        } else {
            NSLog(@"Found chatEntries: %ld ", (unsigned long)matchingChatEntries.count);
            if(matchingChatEntries.count == 0) {
                NSLog(@"Seems this is not a cached message");
            } else {
                for(ChatEntry *chatEntry in matchingChatEntries) {
                    NSLog(@"Chat Data: %@", chatEntry.audio);
                }
                NSLog(@"More than one chatEntry exists.");
            }
        }
        
        NSError *error = [repository endTransaction];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error) {
                [weakSelf.delegate operationFailure:error];
            } else {
                NSLog(@"Operation success");
            }
        });
    });
}

-(void) markAllPreviousMessagesAsRead:(PeppermintChatEntry*)peppermintChatEntry {
    weakself_create();
    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        NSInteger numberOfUpdatedRecords = 0;
        Repository *repository = [Repository beginTransaction];
        NSPredicate *emailPredicate = [ChatEntryModel contactEmailPredicate:peppermintChatEntry.contactEmail];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.dateCreated <= %@", peppermintChatEntry.dateCreated];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:
                                                                        predicate,
                                                                        PREDICATE_UNREAD_MESSAGES,
                                                                        emailPredicate,
                                                                        nil]];
        
        NSDictionary *propertiesToUpdateDictionary = @{ @"isSeen" : @(YES) };
        NSBatchUpdateResult *batchUpdateResult = [repository executeBatchUpdate:[ChatEntry class]
                                                            predicateOrNil:predicate
                                                       propertiesToConnect:propertiesToUpdateDictionary];
        
        if(batchUpdateResult.resultType == NSUpdatedObjectsCountResultType) {
            NSNumber *updatedObjectsCount = (NSNumber*)batchUpdateResult.result;
            numberOfUpdatedRecords = updatedObjectsCount.integerValue;
        } else if(batchUpdateResult.resultType == NSUpdatedObjectIDsResultType) {
            __block NSArray *objectIDs = batchUpdateResult.result;
            numberOfUpdatedRecords = objectIDs.count;            
            dispatch_async(LOW_PRIORITY_QUEUE, ^{
                for (NSManagedObjectID *objectID in objectIDs) {
                    NSManagedObject *managedObject = [repository.managedObjectContext objectWithID:objectID];
                    if (managedObject && [managedObject isKindOfClass:[ChatEntry class]]) {
                        ChatEntry *chatEntry = (ChatEntry*) managedObject;
                        if(chatEntry.messageId.length > 0) {
                            PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
                            [awsService markMessageAsReadWithJwt:peppermintMessageSender.exchangedJwt messageId:chatEntry.messageId];
                        }                        
                    }
                }
            });
        }
                
        NSError *error = [repository endTransaction];
        if(error) {
            [weakSelf.delegate operationFailure:error];
        } else {
            NSLog(@"%ld chatEntry Objects are marked as read.", (long)numberOfUpdatedRecords);
        }
    });
}

#pragma mark - Chat Helper Functions

+(NSPredicate*) contactEmailPredicate:(NSString*) email {
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"self.contactEmail ==[cd] %@", email];
    return emailPredicate;
}

+(NSPredicate*) unreadAudioMessagesPredicateForEmail:(NSString*) email {
    NSPredicate *emailPredicate = [ChatEntryModel contactEmailPredicate:email];
    NSPredicate *audioPredicate = [NSPredicate predicateWithFormat:@"self.duration > 0 OR self.audio != nil"];
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:
                                                               emailPredicate,
                                                               PREDICATE_UNREAD_MESSAGES,
                                                               audioPredicate,
                                                               nil]];
}

-(NSUInteger) unreadMessageCountOfAllChats {
    Repository *repository = [Repository beginTransaction];
    NSArray *unreadChatEntries = [repository getResultsFromEntity:[ChatEntry class] predicateOrNil:PREDICATE_UNREAD_MESSAGES];
    return  unreadChatEntries.count;
}

+(NSSet*) receivedMessagesEmailSet {
#warning "Add DB operations on background, even if they are quick as below. Probably to add block behaviour in function signature ;)"
    Repository *repository = [Repository beginTransaction];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.isSentByMe == %@", @NO];
    NSArray *chatEntries = [repository getResultsFromEntity:[ChatEntry class] predicateOrNil:predicate];
    
    NSMutableSet *mutableSet = [NSMutableSet new];
    for(ChatEntry *chatEntry in chatEntries) {
        [mutableSet addObject:chatEntry.contactEmail];
    }
    return mutableSet;
}

-(void) getLastMessagesForPeppermintContacts:(NSArray<PeppermintContact*>*)unSortedpeppermintContactArray {
    weakself_create();
    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        
        NSMutableArray *contactPredicatesArray = [NSMutableArray new];
        
        NSArray *peppermintContactArray = unSortedpeppermintContactArray;
        
        
        for(PeppermintContact *peppermintContact in peppermintContactArray) {
            NSDate *lastMessageDate = [NSDate maxOfDate1:peppermintContact.lastPeppermintContactDate
                                                   date2:peppermintContact.lastMailClientContactDate];
            
            NSPredicate *timePredicate = [NSPredicate predicateWithFormat:@"self.dateCreated >= %@",
                                          [lastMessageDate dateByAddingTimeInterval:-1]];
            NSPredicate *emailPredicate = [ChatEntryModel contactEmailPredicate:peppermintContact.communicationChannelAddress];
            
            NSPredicate *predicateForContact = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:
                                                                                                   emailPredicate,
                                                                                                   timePredicate,
                                                                                                   nil]];
            [contactPredicatesArray addObject:predicateForContact];
        }
        
        NSPredicate *compoundPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:contactPredicatesArray];
        
        Repository *repository = [Repository beginTransaction];
        NSArray *chatEntryArray = [repository getResultsFromEntity:[ChatEntry class]
                                                    predicateOrNil:compoundPredicate
                                                ascSortStringOrNil:nil
                                               descSortStringOrNil:[NSArray arrayWithObject:@"dateCreated"]];
        
        NSMutableArray<PeppermintContactWithChatEntry*> *resultArray = [NSMutableArray new];
        for(PeppermintContact *peppermintContact in peppermintContactArray) {
            NSPredicate *emailPredicate = [ChatEntryModel contactEmailPredicate:peppermintContact.communicationChannelAddress];
            
            NSArray *filteredArray = [chatEntryArray filteredArrayUsingPredicate:emailPredicate];
            if(filteredArray.count == 0 || filteredArray.count > 1) {
                
                
                NSLog(@"Contact\nlastPeppermint->%@\nlastEmail->%@"
                      , peppermintContact.lastPeppermintContactDate
                      , peppermintContact.lastMailClientContactDate);
                
                NSLog(@"Result should not be empty nor having more than one record. Please update predicates here around.");
                for(PeppermintChatEntry *peppermintChatEntry in filteredArray) {
                    NSLog(@"%@ -> Date:%@ |Subj:%@", peppermintChatEntry.contactEmail, peppermintChatEntry.dateCreated, peppermintChatEntry.subject);
                }
            }
            if(filteredArray.count > 0) {
                PeppermintChatEntry *peppermintChatEntry = [self peppermintChatEntryWith:filteredArray.firstObject];
                PeppermintContactWithChatEntry *peppermintContactWithChatEntry = [PeppermintContactWithChatEntry new];
                
                peppermintContact.lastMailClientContactDate = peppermintChatEntry.dateCreated;
                peppermintContactWithChatEntry.peppermintContact = peppermintContact;
                peppermintContactWithChatEntry.peppermintChatEntry = peppermintChatEntry;
                [resultArray addObject:peppermintContactWithChatEntry];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(weakSelf && [weakSelf.delegate respondsToSelector:@selector(lastMessagesAreUpdated:)]) {
                [weakSelf.delegate lastMessagesAreUpdated:resultArray];
            } else {
                NSLog(@"Delegate did not implement function lastMessagesAreUpdated:");
            }
        });
    });
}

-(NSArray<PeppermintContactWithChatEntry*>*) filter:(NSArray<PeppermintContactWithChatEntry*>*)peppermintContactWithChatEntryArray withFilter:(NSString*) filterText {
    
    NSArray *resultArray = (!peppermintContactWithChatEntryArray) ? [NSArray new] : peppermintContactWithChatEntryArray;
    filterText = [filterText trimmedText];
    if(peppermintContactWithChatEntryArray.count > 0 && filterText.length > 0) {
        NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"peppermintContact.nameSurname CONTAINS[cd] %@", filterText];
        NSPredicate *mailPredicate = [NSPredicate predicateWithFormat:@"peppermintContact.communicationChannelAddress CONTAINS[cd] %@", filterText];
        NSPredicate *subjectPredicate = [NSPredicate predicateWithFormat:@"peppermintChatEntry.subject CONTAINS[cd] %@", filterText];
        NSPredicate *contentPredicate = [NSPredicate predicateWithFormat:@"peppermintChatEntry.mailContent CONTAINS[cd] %@", filterText];
        
        NSPredicate *predicate =
        [NSCompoundPredicate orPredicateWithSubpredicates: [NSArray arrayWithObjects:
                                                            namePredicate,
                                                            mailPredicate,
                                                            subjectPredicate,
                                                            contentPredicate,
                                                            nil]];
        resultArray = [peppermintContactWithChatEntryArray filteredArrayUsingPredicate:predicate];
    }
    
    //Sort Descending
    resultArray = [resultArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        PeppermintContactWithChatEntry *first = (PeppermintContactWithChatEntry*)a;
        PeppermintContactWithChatEntry *second = (PeppermintContactWithChatEntry*)b;
         
        NSDate *firstMaxDate = [NSDate maxOfDate1:first.peppermintContact.lastPeppermintContactDate
                                             date2:first.peppermintContact.lastMailClientContactDate];
        NSDate *secondMaxDate = [NSDate maxOfDate1:second.peppermintContact.lastPeppermintContactDate
                                              date2:second.peppermintContact.lastMailClientContactDate];
        return [secondMaxDate compare:firstMaxDate];
    }];
    
    return resultArray;
}

@end
