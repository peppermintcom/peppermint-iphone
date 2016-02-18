//
//  AutoPlayModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 18/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
@class PeppermintContact;

@interface AutoPlayModel : BaseModel
+ (instancetype) sharedInstance;

-(void) scheduleAutoPlayForPeppermintContact:(PeppermintContact*)peppermintContact;
-(BOOL) isScheduledForPeppermintContactWithNameSurname:(NSString*)nameSurname email:(NSString*)email;
-(void) clearScheduledPeppermintContact;

@end
