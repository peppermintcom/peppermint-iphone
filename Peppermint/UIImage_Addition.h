//
//  UIImage_Addition.h
//  Peppermint
//
//  Created by Okan Kurtulus on 04/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImage_Addition)

- (UIImage*) fixOrientation;
- (UIImage*) resizedImageWithWidth:(int)width height:(int)height;
- (UIImage *)crop;
- (UIImage *)cropToSize:(CGSize)size;

@end
