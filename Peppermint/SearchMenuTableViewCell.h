//
//  SearchMenuTableViewCell.h
//  Peppermint
//
//  Created by Okan Kurtulus on 10/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseTableViewCell.h"

@protocol SearchMenuTableViewCellDelegate <BaseTableViewCellDelegate>
@required
-(void)cellSelectedWithTag:(NSUInteger) cellTag;
@end

@interface SearchMenuTableViewCell : BaseTableViewCell
@property (weak, nonatomic) id<SearchMenuTableViewCellDelegate> delegate;
@property (nonatomic) NSUInteger cellTag;
@property (strong, nonatomic) NSString* iconImageName;
@property (strong, nonatomic) NSString* iconHighlightedImageName;

@property (weak, nonatomic) IBOutlet UIView *cellSeperatorView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

- (IBAction)MenuItemPressed:(id)sender;
- (IBAction)MenuItemFocusLost:(id)sender;
- (IBAction)MenuItemReleased:(id)sender;

@end
