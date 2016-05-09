//
//  AddEmailForSMSContactView.m
//  Peppermint
//
//  Created by Okan Kurtulus on 09/05/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "AddEmailForSMSContactView.h"
#import "CustomContactModel.h"

@interface AddEmailForSMSContactView() <CustomContactModelDelegate>
@end

@implementation AddEmailForSMSContactView {
    CustomContactModel *customContactModel;
    PeppermintContact *peppermintContactToModify;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    customContactModel = [CustomContactModel new];
    customContactModel.delegate = self;
    peppermintContactToModify = nil;
}

+(instancetype) createInstanceWithDelegate:(id<AddEmailForSMSContactViewDelegate>) delegate {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AddEmailForSMSContactView"
                                                             owner:self
                                                           options:nil];
    AddEmailForSMSContactView *addEmailForSMSContactView = (AddEmailForSMSContactView *)[topLevelObjects objectAtIndex:0];
    addEmailForSMSContactView.delegate = delegate;
    return addEmailForSMSContactView;
}

-(void) presentOverView:(UIView*)view forPeppermintContact:(PeppermintContact*)peppermintContact {
    peppermintContactToModify = peppermintContact;
    [self showInView:view];
}

-(void) showInView:(UIView*) view {
    UIView *superView = view.superview;
    if(self.superview != superView) {
        [superView addSubview:self];
    }
    [superView bringSubviewToFront:self];
    self.frame = view.frame;
    [self setNeedsDisplay];
    self.hidden = NO;
}

-(void) hide {
    self.hidden = YES;
}

#pragma mark - Button Actions

-(IBAction)confirm:(id)sender {
    NSLog(@"confirm:");
    [self hide];
}

-(IBAction)decline:(id)sender {
    NSLog(@"decline:");
    [self hide];
}

-(IBAction)dontAskAgainButtonPressed:(id)sender {
    NSLog(@"dontAskAgainButtonPressed:");
}

-(IBAction) sendViaEmailButtonPressed {
    NSLog(@"sendViaEmailButtonPressed");
    
    peppermintContactToModify.communicationChannel = CommunicationChannelEmail;
    peppermintContactToModify.communicationChannelAddress = [NSString stringWithFormat:@"%@@yopmail.com", peppermintContactToModify.nameSurname];
    [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    [customContactModel save:peppermintContactToModify];
    
}

#pragma mark - CustomContactModelDelegate

-(void) customPeppermintContactSavedSucessfully:(PeppermintContact*) peppermintContact {
    [MBProgressHUD hideHUDForView:self.contentView animated:YES];
    [self hide];
    [self.delegate addEmailIsSuccessfullWithEmailContact:peppermintContact];
}

@end
