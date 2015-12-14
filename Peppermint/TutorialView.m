//
//  TutorialView.m
//  Peppermint
//
//  Created by Okan Kurtulus on 14/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "TutorialView.h"

#define TUTORIAL_SHOW_LATENCY        1
#define TUTORIAL_TOOLTIP_DURATION    5

@implementation TutorialView

+(TutorialView*) createInstance {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TutorialView"
                                                         owner:self
                                                       options:nil];
    TutorialView *tutorialView = (TutorialView *)[topLevelObjects objectAtIndex:0];
    return tutorialView;
}

- (void)awakeFromNib {
    self.hidden = YES;
    self.titleLabelFirstPart.font = [UIFont openSansSemiBoldFontOfSize:16];
    self.titleLabelFirstPart.text = LOC(@"Search here for your friend", @"Tutorial Tool Tip");    
    self.titleLabelSecondPart.font = [UIFont openSansSemiBoldFontOfSize:16];
    self.titleLabelSecondPart.text = LOC(@"Then tap and hold to send them an audio message.", @"Tutorial Tool Tip");
    
    self.gestureRecognizers = [NSArray arrayWithObject:
                               [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)]
                               ];
    
    BOOL isTutorialShowed = [defaults_object(DEFAULTS_KEY_TUTORIAL_TOOLTIP_IS_SHOWED) boolValue];
    if(!isTutorialShowed) {
        [NSTimer scheduledTimerWithTimeInterval:TUTORIAL_SHOW_LATENCY target:self selector:@selector(show) userInfo:nil repeats:NO];
    }
}

-(void) show {
    if(self.hidden) {
        self.alpha = 0;
        self.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 1;
        }];
    }
    [NSTimer scheduledTimerWithTimeInterval:TUTORIAL_TOOLTIP_DURATION target:self selector:@selector(hide) userInfo:nil repeats:NO];
}

-(void) hide {
    if(!self.hidden) {
        self.alpha = 1;
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            self.hidden = YES;
        }];
    }
    defaults_set_object(DEFAULTS_KEY_TUTORIAL_TOOLTIP_IS_SHOWED, @(YES));
}

@end
