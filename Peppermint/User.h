//
//  User.h
//  Peppermint
//
//  Created by Okan Kurtulus on 14/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"

@interface User : JSONModel

@property (weak, nonatomic) NSString *email;
@property (weak, nonatomic) NSString *password;
@property (weak, nonatomic) NSString *full_name;

@end
