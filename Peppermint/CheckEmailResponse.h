//
//  CheckEmailResponse.h
//  Peppermint
//
//  Created by Okan Kurtulus on 08/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"

@interface CheckEmailResponse : JSONModel
@property (strong, nonatomic) NSString *email;
@property (assign, nonatomic) BOOL is_verified;
@end
