//
//  RecentContactsModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 10/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import "Repository.h"
#import "PeppermintContact.h"

@protocol RecentContactsModelDelegate <BaseModelDelegate>
-(void) recentPeppermintContactsRefreshed;
-(void) recentPeppermintContactsSavedSucessfully:(NSArray<PeppermintContact*>*) recentContactsArray;
@end

@interface RecentContactsModel : BaseModel
@property (weak, nonatomic) id<RecentContactsModelDelegate> delegate;

-(void) save:(PeppermintContact*) peppermintContact forLastPeppermintContactDate:(NSDate*)lastPeppermintContactDate lastMailClientContactDate:(NSDate*) lastMailClientContactDate;
-(void) saveMultiple:(NSArray<PeppermintContact*>*) peppermintContactArray;
-(void) refreshRecentContactList;

-(NSPredicate*) recentContactPredicate:(PeppermintContact*) peppermintContact;

#pragma mark - Contact List Functions
-(NSMutableArray*) allMessageRecentContactsArray;
-(NSMutableArray*) peppermintMessageRecentContactsArray;
-(NSMutableArray*) mailClientMessageRecentContactsArray;

@end
