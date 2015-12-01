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
        color = [UIColor colorWithRed:1.000f green:0.475f blue:0.333f alpha:1.00f];
    });
    return color;
}

+ (UIColor *) facebookLoginColor {
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:0.243f green:0.337f blue:0.510f alpha:1.00f];
    });
    return color;
}

+ (UIColor *) googleLoginColor {
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:0.980f green:0.459f blue:0.384f alpha:1.00f];
    });
    return color;
}

+ (UIColor *) emailLoginColor {
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:0.361f green:0.769f blue:0.647f alpha:1.00f];
    });
    return color;
}

+ (UIColor *) slideMenuTableViewColor {
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:0.925f green:0.953f blue:0.945f alpha:1.00f];
    });
    return color;
}

+ (UIColor *) slideMenuTableViewCellTextLabelColor {
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:0.180f green:0.741f blue:0.698f alpha:1.00f];
    });
    return color;
}

+ (UIColor *) warningColor {
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:60/255.0 green:157.0/255.0 blue:140.0/255.0 alpha:1.00f];
    });
    return color;
}


+ (UIColor *) continueButtonTitle {
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:0.400f green:0.769f blue:0.639f alpha:1.00f];
    });
    return color;
}

+ (UIColor *) shadowGreen {
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:0.212f green:0.690f blue:0.620f alpha:1.00f];
    });
    return color;
}


@end
