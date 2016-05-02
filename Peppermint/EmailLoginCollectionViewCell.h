//
//  EmailLoginCollectionViewCell.h
//  Peppermint
//
//  Created by Okan Kurtulus on 25/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseCollectionViewCell.h"

@interface EmailLoginCollectionViewCell : BaseCollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *informationlabel;
@property (weak, nonatomic) IBOutlet UILabel *subInformationLabel;

-(void) setIsActive:(BOOL) active;

@end
