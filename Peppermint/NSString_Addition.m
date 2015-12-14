//
//  NSString_Addition.m
//  Peppermint
//
//  Created by Okan Kurtulus on 05/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "NSString_Addition.h"

@implementation NSString (NSString_Addition)

-(BOOL)isValidEmail
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    BOOL isValidForExtraControls = ![self containsString:@".."]
    && ![self containsString:@".@"]
    && self.length > 3
    && !([self characterAtIndex:0] == [@"." characterAtIndex:0]);
    
    return [emailTest evaluateWithObject:self]
    && isValidForExtraControls;
}

-(BOOL)isPasswordLengthValid
{
    NSString *filteredString = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    return filteredString.length >= MIN_PASSWORD_LENGTH;
}



-(NSString *) randomStringWithLength: (int) len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (NSUInteger i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex:arc4random_uniform((NSUInteger)[letters length])]];
    }
    return randomString;
}

@end
