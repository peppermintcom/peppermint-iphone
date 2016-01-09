//
//  AboutViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 08/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"

@interface AboutViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *privacyPolicyLabel;

+(instancetype) createInstance;

@end
