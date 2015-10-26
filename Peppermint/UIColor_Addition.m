//
//  UIColor_Addition.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "UIColor_Addition.h"

@implementation UIColor (UIColor_Addition)

+ (UIColor *) peppermintGreen {
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:0.431f green:0.776f blue:0.635f alpha:1.00f];
    });
    return color;
}

+ (UIColor *) cellSeperatorGray {
    static dispatch_once_t onceToken;
    static UIColor *color;    
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:0.835f green:0.855f blue:0.847f alpha:1.00f];
    });
    return color;
}

+ (UIColor *) viaInformationLabelTextGreen {
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:0.184f green:0.741f blue:0.698f alpha:1.00f];
    });
    return color;
}

+ (UIColor *) textFieldTintGreen {
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:0.549f green:0.659f blue:0.647f alpha:1.00f];
    });
    return color;
}

+ (UIColor *) emptyResultTableViewCellHeaderLabelTextcolorGray {
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:0.824f green:0.863f blue:0.859f alpha:1.00f];
    });
    return color;
}

+ (UIColor *) recordingNavigationsubTitleGreen {
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:0.000f green:0.455f blue:0.420f alpha:1.00f];
    });
    return color;
}

+ (UIColor *) progressContainerViewGray {
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:0.839f green:0.894f blue:0.882f alpha:1.00f];
    });
    return color;
}

+ (UIColor *) progressCoverViewGreen {
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:0.012f green:0.518f blue:0.475f alpha:1.00f];
    });
    return color;
}

+ (UIColor *) peppermintCancelOrange {
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:0.961f green:0.420f blue:0.294f alpha:1.00f];
    });
    return color;
}



@end
