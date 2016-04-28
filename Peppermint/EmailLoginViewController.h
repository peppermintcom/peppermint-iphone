//
//  EmailLoginViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 25/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseLoginViewController.h"

@interface EmailLoginViewController : BaseLoginViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UILabel *withoutLoginLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
