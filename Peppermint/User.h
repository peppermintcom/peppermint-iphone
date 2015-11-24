//
//  User.h
//  Peppermint
//
//  Created by Okan Kurtulus on 14/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"

@interface User : JSONModel

@property (weak, nonatomic) NSString<Optional> *account_id;
@property (weak, nonatomic) NSString *email;
@property (weak, nonatomic) NSString<Optional> *password;
@property (weak, nonatomic) NSString *full_name;
@property (weak, nonatomic) NSNumber<Optional> *is_verified;

@end
