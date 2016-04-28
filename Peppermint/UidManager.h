//
//  UidManager.h
//  Peppermint
//
//  Created by Okan Kurtulus on 23/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"

@interface UidManager : BaseModel
+ (instancetype) sharedInstance;

-(NSNumber*) getUidForUsername:(NSString*) sessionUserName folder:(NSString*) folderName;
-(void) save:(NSNumber*)uidNumber forUsername:(NSString*)sessionUserName folder:(NSString*) folderName;
@end
