//
//  NSString_Addition.m
//  Peppermint
//
//  Created by Okan Kurtulus on 05/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "NSString_Addition.h"
#import <CoreText/CTFramesetter.h>

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

-(BOOL) isValidPhoneNumber {
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [self rangeOfCharacterFromSet: nonNumbers];
    BOOL isAllDigits = r.location == NSNotFound;
    
    return isAllDigits
    && self.length > MIN_LENGTH_FOR_PHONE_NUMBER
    && self.length <= MAX_LENGTH_FOR_PHONE_NUMBER;
}

-(BOOL)isPasswordLengthValid
{
    NSString *filteredString = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    return filteredString.length >= MIN_PASSWORD_LENGTH;
}

-(NSString *) randomStringWithLength: (NSUInteger) length {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    for (NSUInteger i=0; i<length; i++) {
        NSUInteger index = (NSUInteger)arc4random_uniform((int32_t)[letters length]);
        [randomString appendFormat: @"%C", [letters characterAtIndex:index]];
    }
    return randomString;
}

-(NSString*) trimmedText {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString*) limitTo:(NSUInteger)length {
    NSString *updatedText = self;
    if(length < self.length && length > 0) {
        NSRange range = [self rangeOfComposedCharacterSequencesForRange:(NSRange){0, length}];
        updatedText = [self substringWithRange:range];
        updatedText = [updatedText stringByAppendingString:@" …"];
    }
    return updatedText;
}


+(CGFloat) widthOfText:(NSString*)text withSize:(NSUInteger)size andHeight:(CGFloat) height {
    NSMutableAttributedString *attrText = [NSMutableAttributedString new];
    [attrText addText:text ofSize:size ofColor:[UIColor clearColor] andFont:[UIFont openSansSemiBoldFontOfSize:size]];
    CGRect paragraphRect = [attrText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                                  options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                  context:nil];
    return paragraphRect.size.width;
}

-(NSString*) limitToFitInWidth:(CGFloat)width height:(CGFloat)height andFonttSize:(NSUInteger)size {
    NSString *trimmedText = [NSString stringWithString:self];
    while ([NSString widthOfText:trimmedText withSize:size andHeight:height] > width) {
        trimmedText = [self limitTo:trimmedText.length - 3];
    }
    return trimmedText;
}

-(NSString*) normalizeText {
    //Fix locale
    NSString *nonLocaleString = [self stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    
    //Decompose text
    NSMutableString *stringToModify = [[nonLocaleString decomposedStringWithCanonicalMapping] mutableCopy];
    //Transform
    CFStringTransform((__bridge CFMutableStringRef)stringToModify, NULL, kCFStringTransformStripCombiningMarks, NO);
    //Check to contain just letters
    NSMutableCharacterSet *availableCharSet = [NSMutableCharacterSet new];
    //[availableCharSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
    [availableCharSet formUnionWithCharacterSet:[self asciiCharacterSet]];
    [availableCharSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    
    NSData * utf8Data = [stringToModify dataUsingEncoding:NSUTF8StringEncoding];
    NSString *utf8String = [[NSString alloc] initWithData:utf8Data encoding:NSUTF8StringEncoding];
    
    return utf8String;
    /*
     NSString *resultText = [[utf8String componentsSeparatedByCharactersInSet:
                         [availableCharSet invertedSet]] componentsJoinedByString:@"_"];
     return resultText;
     */    
}

-(NSCharacterSet*) asciiCharacterSet {
    NSMutableString *asciiCharacters = [NSMutableString string];    
    //http://www.ascii-codes.com/cp855.html
    //Standard Characters
    for (NSInteger i = 32; i <= 127; i++)  {
        [asciiCharacters appendFormat:@"%c", (char)i];
    }
    //Extended Characters
    for (NSInteger i = 128; i <= 255; i++)  {
        [asciiCharacters appendFormat:@"%c", (char)i];
    }
    return [NSCharacterSet characterSetWithCharactersInString:asciiCharacters];
}

@end
