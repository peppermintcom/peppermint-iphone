//
//  LoginRequest.h
//  Peppermint
//
//  Created by Okan Kurtulus on 14/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"

@interface LoginRequest : JSONModel
@property (strong, nonatomic) NSString *api_key;
@end
