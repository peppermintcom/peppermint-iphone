//
//  AboutViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 08/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "AboutViewController.h"
#import "DeviceModel.h"
#import "GoogleSpeechModel.h"

#define TITLE_TEXT_SIZE             20
#define PEPPERMINT_TEXT_SIZE        27
#define VERSION_TEXT_SIZE           13
#define PRIVACY_TEXT_SIZE           15


@interface AboutViewController ()
@property (strong, nonatomic) GoogleSpeechModel *googleSpeechModel;
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //Title
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont openSansSemiBoldFontOfSize:TITLE_TEXT_SIZE];
    self.titleLabel.text = LOC(@"About",@"About");
    
    //Version
    NSMutableAttributedString *versionText = [NSMutableAttributedString new];
    [versionText addText:LOC(@"Peppermint.com", @"Peppermint.com") ofSize:PEPPERMINT_TEXT_SIZE ofColor:[UIColor peppermintComGreen] andFont:[UIFont openSansSemiBoldFontOfSize:PEPPERMINT_TEXT_SIZE]];
    [versionText addText:@"\n" ofSize:17 ofColor:[UIColor clearColor]];
    [versionText addText:[NSString stringWithFormat:@"%@ %@", LOC(@"Version", @"Version Title"),[DeviceModel applicationVersion]] ofSize:VERSION_TEXT_SIZE ofColor:[UIColor emptyResultTableViewCellHeaderLabelTextcolorGray] andFont:[UIFont openSansSemiBoldFontOfSize:VERSION_TEXT_SIZE]];
    [versionText centerText];
    self.versionLabel.attributedText = versionText;
    
    //Privacy
    self.privacyPolicyLabel.textColor = [UIColor privacyPolicyGreen];
    self.privacyPolicyLabel.font = [UIFont openSansSemiBoldFontOfSize:PRIVACY_TEXT_SIZE];
    self.privacyPolicyLabel.text = LOC(@"Privacy Policy & Terms of Use",@"Privacy Policy");
    [self.privacyPolicyLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(privacyLabelPressed)]];
}

-(void) privacyLabelPressed {
    NSURL *url = [NSURL URLWithString:PEPPERMINT_PRIVACY_ADDRESS];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+(instancetype) createInstance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_MAIN bundle:[NSBundle mainBundle]];
    AboutViewController *aboutViewController = [storyboard instantiateViewControllerWithIdentifier:VIEWCONTROLLER_ABOUT];
    return aboutViewController;
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.googleSpeechModel = [GoogleSpeechModel new];
    [self.googleSpeechModel recordAudio:nil];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.googleSpeechModel stopAudio:nil];
}

#pragma mark - CloseButton

-(IBAction)backButtonPressed:(id)sender {
    if(!self.navigationController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
