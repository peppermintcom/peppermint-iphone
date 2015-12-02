//
//  ContactInformationTableViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 30/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "ContactInformationTableViewCell.h"

@implementation ContactInformationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.titleLabel.layer.cornerRadius = SHOW_ALL_CONTACRS_CORNER_RADIUS;
    
    UITapGestureRecognizer *tapRecogniser = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(contactInformationButtonTapped)];
    [self.titleLabel setGestureRecognizers:[NSArray arrayWithObject:tapRecogniser]];
    [self.titleLabel setUserInteractionEnabled:YES];
}

-(void) contactInformationButtonTapped {
    [self.delegate contactInformationButtonPressed];
}

-(void) setViewForAddNewContact {
    self.titleLabel.backgroundColor = [UIColor emailLoginColor];
    self.titleLabel.layer.shadowOffset = CGSizeMake(0, 4);
    self.titleLabel.layer.shadowColor = [UIColor shadowGreen].CGColor;
    self.titleLabel.layer.shadowOpacity = 1;
    self.titleLabel.layer.shadowRadius = 1;
    [self setText:LOC(@"Add Contact", @"Title") withImageNamed:@"icon_add" ofSize:17 andColor:[UIColor whiteColor]];
}

-(void) setViewForShowAllContacts {
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.layer.shadowOffset = CGSizeMake(0, 0);
    self.titleLabel.layer.shadowColor = [UIColor clearColor].CGColor;
    self.titleLabel.layer.shadowOpacity = 0;
    self.titleLabel.layer.shadowRadius = 0;
    [self setText:LOC(@"Show All Contacts", @"Title") withImageNamed:@"icon_all" ofSize:17 andColor:[UIColor emailLoginColor]];
}

-(void) setText:(NSString*)text withImageNamed:(NSString*)imageName ofSize:(CGFloat)size andColor:(UIColor*) color {
    NSMutableAttributedString *attrText = [NSMutableAttributedString new];
    [attrText addText:@"   " ofSize:size ofColor:color];
    [attrText addImageNamed:imageName ofSize:size];
    [attrText addText:@" " ofSize:size ofColor:color];
    [attrText addText:text ofSize:size ofColor:color andFont:[UIFont openSansSemiBoldFontOfSize:size]];
    [attrText addText:@"   " ofSize:size ofColor:color];
    [self.titleLabel setAttributedText:attrText];
    [self.titleLabel sizeToFit];
}

@end
