//
//  GoogleContactsModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 23/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import "GDataContacts.h"

@protocol GoogleContactsModelDelegate <BaseModelDelegate>
-(void) syncGoogleContactsSuccess;
@end

@interface GoogleContactsModel : BaseModel
@property (weak, nonatomic) id<GoogleContactsModelDelegate> delegate;

+(NSString*) scopeForGoogleContacts;
-(void) syncGoogleContactsWithFetcherAuthorizer:(id<GTMFetcherAuthorizationProtocol>)fetcherAuthorizer;

@end
