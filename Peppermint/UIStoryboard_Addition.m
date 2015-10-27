//
//  UIStoryboard_Addition.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "UIStoryboard_Addition.h"

UIStoryboard *_mainStoryboard = nil;

@implementation UIStoryboard (UIStoryboard_Addition)

+ (instancetype)LDMainStoryboard {
    if (!_mainStoryboard) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *storyboardName = [bundle objectForInfoDictionaryKey:@"UIMainStoryboardFile"];
        _mainStoryboard = [UIStoryboard storyboardWithName:storyboardName bundle:bundle];
    }
    return _mainStoryboard;
}

+ (NSString*) LDMainStoryboardName {
    return [[UIStoryboard LDMainStoryboard] valueForKey:@"name"];
}
@end
