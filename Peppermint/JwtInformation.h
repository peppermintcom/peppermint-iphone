//
//  JwtInformation.h
//  Peppermint
//
//  Created by Okan Kurtulus on 11/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface JwtInformation : JSONModel
@property (assign, nonatomic) NSTimeInterval exp;
@property (assign, nonatomic) NSTimeInterval iat;
@property (strong, nonatomic) NSString *iss;
@property (strong, nonatomic) NSString *sub;

+(instancetype) instancewithJwt:(NSString*)jwt andError:(JSONModelError**) error;

@end
