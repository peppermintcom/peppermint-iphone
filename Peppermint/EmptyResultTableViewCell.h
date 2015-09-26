//
//  EmptyResultTableViewCell.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface EmptyResultTableViewCell : BaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel *footerLabel;

-(void) setVisibiltyOfExplanationLabels:(BOOL) visibility;

@end
