//
//  FastReplyModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 21/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import "PeppermintContact.h"

@interface FastReplyModel : BaseModel
@property (strong, nonatomic) PeppermintContact* peppermintContact;

+ (instancetype) sharedInstance;
-(BOOL) setFastReplyContactWithNameSurname:(NSString*)nameSurname email:(NSString*)email;
-(void) cleanFastReplyContact;
-(BOOL) doesFastReplyContactsContains:(NSString*) filterText;

@end
