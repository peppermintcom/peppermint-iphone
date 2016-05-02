//
//  EmailLoginViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 25/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "EmailLoginViewController.h"

#define FONT_SIZE               17

#define NUMBER_OF_ITEMS         7
#define ITEM_GOOGLE             0
#define ITEM_OUTLOOK            1
#define ITEM_YAHOO_MAIL         2
#define ITEM_OFFICE_365         3
#define ITEM_AOL                4
#define ITEM_ICLOUD             5
#define ITEM_MAIL_RU            6

@implementation EmailLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.loginLabel.textColor = [UIColor whiteColor];
    self.loginLabel.font = [UIFont openSansSemiBoldFontOfSize:FONT_SIZE];
    
    NSMutableAttributedString *titleText = [NSMutableAttributedString new];
    [titleText addText:LOC(@"To start seeing how easy it is to reply to emails, add an account", @"title") ofSize:FONT_SIZE ofColor:[UIColor whiteColor] andFont:[UIFont openSansSemiBoldFontOfSize:FONT_SIZE]];
    [titleText centerText];
    self.loginLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.loginLabel.attributedText = titleText;
    
    NSMutableAttributedString *informationString = [NSMutableAttributedString new];
    [informationString addText:LOC(@"Don't want to create an account yet? click here", @"Message First part") ofSize:FONT_SIZE ofColor:[UIColor whiteColor] andFont:[UIFont openSansSemiBoldFontOfSize:FONT_SIZE]];
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle), NSBackgroundColorAttributeName: [UIColor clearColor]};
    NSRange range = [informationString.string rangeOfString:@"? "];
    range.location += 2;
    range.length = informationString.string.length - range.location;
    if(range.location > 0 && range.length > 0) {
        [informationString addAttributes:underlineAttribute range:range];
    }
    
    [informationString centerText];
    self.withoutLoginLabel.attributedText = informationString;
    [self.withoutLoginLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(withoutLoginLabelPressed:)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning");
}

#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return NUMBER_OF_ITEMS;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EmailLoginCollectionViewCell *cell = [CellFactory cellEmailLoginCollectionViewCellFromCollectionView:collectionView forIndexPath:indexPath];
    if(indexPath.row == ITEM_GOOGLE) {
        cell.iconImageView.image = [UIImage imageNamed:@"icon_gmail"];
        cell.informationlabel.text = LOC(@"GMail", @"MailBox");
        [cell setIsActive:YES];
    } else if (indexPath.row == ITEM_OUTLOOK) {
        cell.iconImageView.image = [UIImage imageNamed:@"icon_outlook"];
        cell.informationlabel.text = LOC(@"Outlook.com", @"MailBox");
        [cell setIsActive:NO];
    } else if (indexPath.row == ITEM_YAHOO_MAIL) {
        cell.iconImageView.image = [UIImage imageNamed:@"icon_yahoo_mail"];
        cell.informationlabel.text = LOC(@"Yahoo! Mail", @"MailBox");
        [cell setIsActive:NO];
    } else if (indexPath.row == ITEM_OFFICE_365) {
        cell.iconImageView.image = [UIImage imageNamed:@"icon_office_365"];
        cell.informationlabel.text = LOC(@"Office 365", @"MailBox");
        [cell setIsActive:NO];
    } else if (indexPath.row == ITEM_AOL) {
        cell.iconImageView.image = [UIImage imageNamed:@"icon_aol"];
        cell.informationlabel.text = LOC(@"AOL Mail", @"MailBox");
        [cell setIsActive:NO];
    } else if (indexPath.row == ITEM_ICLOUD) {
        cell.iconImageView.image = [UIImage imageNamed:@"icon_cloud"];
        cell.informationlabel.text = LOC(@"iCloud", @"MailBox");
        [cell setIsActive:NO];
    } else if (indexPath.row == ITEM_MAIL_RU) {
        cell.iconImageView.image = [UIImage imageNamed:@"icon_mail_at"];
        cell.informationlabel.text = LOC(@"Mail.ru", @"MailBox");
        [cell setIsActive:NO];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_SIZE_EMAILLOGIN_COLLECTIONVIEWCELL;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isConnectionValid = [[ConnectionModel sharedInstance] isInternetReachable];
    if(isConnectionValid) {
        NSDate *nowDate = [NSDate new];
        if(!self.referanceDate || [nowDate timeIntervalSinceDate:self.referanceDate] > 1) {
            self.referanceDate = nowDate; //Prevent multiple touch!
            
            NSInteger index = indexPath.row;
            LoginNavigationViewController *loginNavigationViewController = (LoginNavigationViewController*)self.navigationController;
            if(index == ITEM_GOOGLE) {
                [PeppermintMessageSender sharedInstance].loginSource = LOGINSOURCE_GOOGLE;
                [loginNavigationViewController.loginModel performGoogleLogin];
            } else {
                NSLog(@"Option is not active yet. Coming soon.");
            }
        }
    } else {
        [self showInternetIsNotReachableError];
    }
}

@end
