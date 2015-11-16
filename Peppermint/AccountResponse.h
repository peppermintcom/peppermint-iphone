//
//  AccountResponse.h
//  Peppermint
//
//  Created by Okan Kurtulus on 14/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"
#import "User.h"

@interface AccountResponse : JSONModel
@property (strong, nonatomic) NSString *at;
@property (strong, nonatomic) User *u;
@end
