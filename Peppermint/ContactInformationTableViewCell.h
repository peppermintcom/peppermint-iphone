//
//  ContactInformationTableViewCell.h
//  Peppermint
//
//  Created by Okan Kurtulus on 30/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseTableViewCell.h"

@protocol ContactInformationTableViewCellDelegate <BaseTableViewCellDelegate>
-(void) contactInformationButtonPressed;
@end

@interface ContactInformationTableViewCell : BaseTableViewCell
@property (weak, nonatomic) id<ContactInformationTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

-(void) setViewForAddNewContact;
-(void) setViewForShowAllContacts;

@end