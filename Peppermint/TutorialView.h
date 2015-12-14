//
//  TutorialView.h
//  Peppermint
//
//  Created by Okan Kurtulus on 14/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseCustomView.h"

@interface TutorialView : BaseCustomView

@property (weak, nonatomic) IBOutlet UILabel *titleLabelFirstPart;
@property (weak, nonatomic) IBOutlet UILabel *titleLabelSecondPart;

+(TutorialView*) createInstance;
-(void) show;
-(void) hide;


@end
