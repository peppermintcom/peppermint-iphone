//
//  ContactInformationTableViewCell.h
//  Peppermint
//
//  Created by Okan Kurtulus on 30/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseTableViewCell.h"
@class ContactInformationTableViewCell;

@protocol ContactInformationTableViewCellDelegate <BaseTableViewCellDelegate>
-(void) contactInformationButtonPressed:(ContactInformationTableViewCell*) cell;
@end

@interface ContactInformationTableViewCell : BaseTableViewCell
@property (weak, nonatomic) id<ContactInformationTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *headerSeperatorView;

-(void) setViewForAddNewContact;
-(void) setViewForShowAllContacts;
-(void) setViewForShowResultsFromPhoneContacts;

@end