//
//  CountryRow.h
//  Peppermint
//
//  Created by Yan Saraev on 11/26/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseCustomView.h"

@interface CountryRow : BaseCustomView

@property (strong, nonatomic) NSString * countryCode;
@property (weak, nonatomic) IBOutlet UIImageView * iconImageView;
@property (weak, nonatomic) IBOutlet UILabel * titleLabel;
@property (weak, nonatomic) IBOutlet UILabel * descriptionLabel;

@end
