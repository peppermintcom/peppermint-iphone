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
-(void) recentPeppermintContactsSavedSucessfully:(NSArray*) recentContactsArray;
@end

@interface RecentContactsModel : BaseModel
@property (weak, nonatomic) id<RecentContactsModelDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *contactList;

-(void) save:(PeppermintContact*) peppermintContact forContactDate:(NSDate*) contactDate;
-(void) saveMultiple:(NSArray*) peppermintContactArray;
-(void) refreshRecentContactList;

-(NSPredicate*) recentContactPredicate:(PeppermintContact*) peppermintContact;
@end
