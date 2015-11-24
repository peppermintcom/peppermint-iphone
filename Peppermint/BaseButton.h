//
//  BaseButton.h
//  Peppermint
//
//  Created by Yan Saraev on 11/24/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseButton : UIButton

@property (strong, nonatomic) IBInspectable UIImage * ppm_highlightImage;
@property (strong, nonatomic) UIImageView * ppm_highlightOverlay;

@end
