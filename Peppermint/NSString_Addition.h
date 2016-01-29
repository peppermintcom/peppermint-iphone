//
//  NSString_Addition.h
//  Peppermint
//
//  Created by Okan Kurtulus on 05/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSString_Addition)

- (BOOL)isValidEmail;
-(BOOL)isPasswordLengthValid;
-(NSString *) randomStringWithLength: (NSUInteger) length;
-(NSString*) trimmedText;
-(NSString*) limitTo:(NSUInteger)length;
+(CGFloat) widthOfText:(NSString*)text withSize:(NSUInteger)size andHeight:(CGFloat) height;
-(NSString*) limitToFitInWidth:(CGFloat)width height:(CGFloat)height andFonttSize:(NSUInteger)size;
@end
