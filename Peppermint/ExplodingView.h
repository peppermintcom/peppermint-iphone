//
//  ExplodingView.h
//  Peppermint
//
//  Created by Okan Kurtulus on 23/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseCustomView.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

@interface LPParticleLayer : CALayer
@property (nonatomic, strong) UIBezierPath *particlePath;
@end

typedef void(^ExplodeCompletion)(void);

@interface ExplodingView : UIImageView
@property (nonatomic, copy) ExplodeCompletion completionCallback;

+(ExplodingView*) createInstanceFromView:(UIView*) view;
- (void)lp_explode;
- (void)lp_explodeWithCallback:(ExplodeCompletion)callback;


@end
