//
//  ChatContactTableViewCell.h
//  Peppermint
//
//  Created by Okan Kurtulus on 19/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ContactTableViewCell.h"

@interface ChatContactTableViewCell : ContactTableViewCell

@property(weak, nonatomic) IBOutlet UILabel *rightDateLabel;
@property(weak, nonatomic) IBOutlet UILabel *rightMessageCounterLabel;

@end
