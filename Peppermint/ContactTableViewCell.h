//
//  ContactTableViewCell.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseTableViewCell.h"

@protocol ContactTableViewCellDelegate <BaseTableViewCellDelegate>
@required
-(void) didShortTouchOnIndexPath:(NSIndexPath*) indexPath location:(CGPoint) location;
-(void) didBeginItemSelectionOnIndexpath:(NSIndexPath*) indexPath location:(CGPoint) location;
-(void) didCancelItemSelectionOnIndexpath:(NSIndexPath*) indexPath location:(CGPoint) location;
-(void) didFinishItemSelectionOnIndexPath:(NSIndexPath*) indexPath location:(CGPoint) location;
@end

@interface ContactTableViewCell : BaseTableViewCell
@property(weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property(weak, nonatomic) IBOutlet UIView *cellSeperatorView;
@property (weak, nonatomic) IBOutlet UIButton* cellActionButton;
@property(weak, nonatomic) id<ContactTableViewCellDelegate> delegate;
@property(weak, nonatomic) UITableView *tableView;

-(void) setInformationWithNameSurname:(NSString*)contactNameSurname communicationChannelAddress:(NSString*)contactCommunicationChannelAddress;
-(void) setInformationWithNameSurname:(NSString*)contactNameSurname communicationChannelAddress:(NSString*)contactCommunicationChannelAddress andIconImage:(UIImage*) image;
-(void) setAvatarImage:(UIImage*) image ;
@end
