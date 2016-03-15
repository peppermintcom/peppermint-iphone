//
//  BaseTableViewCell.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BaseTableViewCellDelegate <NSObject>
@optional
-(void) operationFailure:(NSError*) error;
@end

@interface BaseTableViewCell : UITableViewCell
@property(strong, nonatomic) NSIndexPath *indexPath;
@end
