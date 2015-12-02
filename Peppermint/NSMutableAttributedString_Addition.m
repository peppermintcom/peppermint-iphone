//
//  NSMutableAttributedString_Addition.m
//  Peppermint
//
//  Created by Okan Kurtulus on 02/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "NSMutableAttributedString_Addition.h"
#import "JPStringAttribute.h"

#define default_font(__size) [UIFont openSansBoldFontOfSize:(__size)]

@implementation NSMutableAttributedString (NSMutableAttributedString_Addition)

-(NSMutableAttributedString*) centerText {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [self addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self length])];
    return self;
}

-(NSMutableAttributedString*) addImageNamed:(NSString*) imageName ofSize:(NSInteger) size {
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:imageName];
    attachment.bounds = CGRectMake(0, (self.size.height - size)/-2, size, size);
    NSAttributedString *tickAttachment = [NSAttributedString attributedStringWithAttachment:attachment];
    [self appendAttributedString:tickAttachment];
    return self;
}

-(NSMutableAttributedString*) addText:(NSString*)text ofSize:(NSUInteger)size ofColor:(UIColor*)color {
    return [self addText:text ofSize:size ofColor:color andFont:default_font(size)];
}

-(NSMutableAttributedString*) addText:(NSString*)text ofSize:(NSUInteger)size ofColor:(UIColor*)color andFont:(UIFont*) font {
    JPStringAttribute *infoAttr = [JPStringAttribute new];
    infoAttr.foregroundColor = color;
    infoAttr.font = font;
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:text
                                                                   attributes:infoAttr.attributedDictionary];
    [self appendAttributedString:attrText];
    return self;
}

@end
