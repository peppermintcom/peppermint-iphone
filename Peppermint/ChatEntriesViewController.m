//
//  ChatEntriesViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 19/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatEntriesViewController.h"

@interface ChatEntriesViewController ()

@end

@implementation ChatEntriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.avatarImageView.image = [UIImage imageWithData:self.chat.avatarImageData];
    NSMutableAttributedString *attrText = [NSMutableAttributedString new];
    [attrText addText:self.chat.nameSurname ofSize:17 ofColor:[UIColor whiteColor] andFont:[UIFont openSansSemiBoldFontOfSize:17]];
    [attrText addText:@"\n" ofSize:12 ofColor:[UIColor clearColor]];
    [attrText addText:self.chat.communicationChannelAddress ofSize:13 ofColor:[UIColor recordingNavigationsubTitleGreen]];
    [attrText centerText];
    self.titleLabel.attributedText = attrText;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
