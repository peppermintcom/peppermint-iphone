//
//  NSMutableAttributedString_Addition.h
//  Peppermint
//
//  Created by Okan Kurtulus on 02/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (NSMutableAttributedString_Addition)

-(NSMutableAttributedString*) centerText;
-(NSMutableAttributedString*) addImageNamed:(NSString*) imageName ofSize:(NSInteger) size;
-(NSMutableAttributedString*) addText:(NSString*)text ofSize:(NSUInteger)size ofColor:(UIColor*)color;
-(NSMutableAttributedString*) addText:(NSString*)text ofSize:(NSUInteger)size ofColor:(UIColor*)color andFont:(UIFont*) font;

@end
