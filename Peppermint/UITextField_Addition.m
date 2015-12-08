//
//  UITextField_Addition.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "UITextField_Addition.h"

@implementation UITextField (UITextField_Addition)

- (void)selectTextAtRange:(NSRange)range {
    UITextPosition *start = [self positionFromPosition:[self beginningOfDocument]
                                                     offset:range.location];
    UITextPosition *end = [self positionFromPosition:start
                                                   offset:range.length];
    [self setSelectedTextRange:[self textRangeFromPosition:start toPosition:end]];
}

-(NSString*) getTextContentWithRange:(NSRange)range replacementString:(NSString *)string {
    NSString* text = [self.text stringByReplacingCharactersInRange:range withString:string];
    return text;
}

-(void) setTextContentInRange:(NSRange)range replacementString:(NSString *)string {
    NSRange newRange = NSMakeRange(range.location + string.length, 0);
    NSString* text = [self.text stringByReplacingCharactersInRange:range withString:string];
    self.text = text;
    [self selectTextAtRange:newRange];
}

@end
