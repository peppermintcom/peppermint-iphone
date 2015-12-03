//
//  User.h
//  Peppermint
//
//  Created by Okan Kurtulus on 14/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"

@interface User : JSONModel

@property (strong, nonatomic) NSString<Optional> *account_id;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString<Optional> *password;
@property (strong, nonatomic) NSString<Optional> *full_name;
@property (strong, nonatomic) NSNumber<Optional> *is_verified;
@end
