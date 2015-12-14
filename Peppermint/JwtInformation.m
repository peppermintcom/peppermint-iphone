//
//  JwtInformation.m
//  Peppermint
//
//  Created by Okan Kurtulus on 11/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "JwtInformation.h"

@implementation JwtInformation


+(instancetype) instancewithJwt:(NSString*)jwt andError:(JSONModelError**) error {
    JwtInformation *jwtInformation = nil;
    NSArray *jwtComponents = [jwt componentsSeparatedByString:@"."];
    if(jwtComponents.count == 3 ) {
        NSString *jwtInfo = [jwtComponents objectAtIndex:1];
        jwtInfo = [NSString stringFromBase64String:jwtInfo];
        jwtInformation = [[JwtInformation alloc] initWithString:jwtInfo error:(&*error)];
    }
    return jwtInformation;
}

@end
