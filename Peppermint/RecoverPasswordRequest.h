//
//  RecoverPasswordRequest.h
//  Peppermint
//
//  Created by Okan Kurtulus on 09/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"

@interface RecoverPasswordRequest : JSONModel
@property (strong, nonatomic) NSString *api_key;
@property (strong, nonatomic) NSString *email;
@end
