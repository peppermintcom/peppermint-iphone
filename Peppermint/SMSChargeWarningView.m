//
//  SMSChargeWarningView.m
//  Peppermint
//
//  Created by Okan Kurtulus on 04/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "SMSChargeWarningView.h"
#import "ContactsModel.h"

#define SIZE_BIG        17
#define SIZE_MIDDLE     15
#define SIZE_SMALL      13

@implementation SMSChargeWarningView {
    BOOL isUserConfirming;
    NSString    *contactNameSurname;
    NSString    *alternateCommunicationChannelAddress;
    UITextField *alternateCommunicationChannelTextField;
}

+(SMSChargeWarningView*) createInstanceWithDelegate:(id<SMSChargeWarningViewDelegate>) delegate {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SMSChargeWarningView"
                                                             owner:self
                                                           options:nil];
    SMSChargeWarningView *smsChargeWarningView = (SMSChargeWarningView *)[topLevelObjects objectAtIndex:0];
    smsChargeWarningView.delegate = delegate;
    return smsChargeWarningView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.hidden = YES;
    contactNameSurname = nil;
    
    self.contentView.layer.cornerRadius = 15;
    self.contentView.backgroundColor = [UIColor peppermintGray248];
    
    [self initTitleText];
    [self initButtons];
}

-(void) initTitleText {
    NSMutableAttributedString *titleText = [NSMutableAttributedString new];
    [titleText addText:LOC(@"Sending via SMS", @"title")
                ofSize:SIZE_BIG
               ofColor:[UIColor blackColor]
               andFont:[UIFont openSansBoldFontOfSize:SIZE_BIG]];
    
    [titleText addText:@"\n\n" ofSize:SIZE_BIG ofColor:[UIColor clearColor]];
    [titleText centerText];
    [titleText addText:LOC(@"Sending via SMS may cost you money. Continue?", @"information")
                ofSize:SIZE_MIDDLE
               ofColor:[UIColor blackColor]
               andFont:[UIFont openSansSemiBoldFontOfSize:SIZE_MIDDLE]];
    
    self.titleLabel.attributedText = titleText;
}

-(void) initMailText {
    NSMutableAttributedString *sendViaEmailText = [NSMutableAttributedString new];
    [sendViaEmailText addText:LOC(@"Send to Email Instead", @"title")
                       ofSize:SIZE_MIDDLE
                      ofColor:[UIColor viaInformationLabelTextGreen]
                      andFont:[UIFont openSansBoldFontOfSize:SIZE_MIDDLE]];
    
    [sendViaEmailText addText:@"\n" ofSize:SIZE_MIDDLE ofColor:[UIColor clearColor]];
    
    [sendViaEmailText addText:[self mailTextForContactName:contactNameSurname]
                       ofSize:SIZE_SMALL
                      ofColor:[UIColor viaInformationLabelTextGreen]
                      andFont:[UIFont openSansSemiBoldFontOfSize:SIZE_MIDDLE]];
    
    [sendViaEmailText centerText];
    self.sendViaEmailLabel.attributedText = sendViaEmailText;
}

-(NSString*) mailTextForContactName:(NSString*) contactName {
    NSString *mailText = LOC(@"Add email address", @"Add email address");
    NSPredicate *predicate = [ContactsModel contactPredicateWithNameSurnameMatchExact:contactName communicationChannel:CommunicationChannelEmail];
    NSArray *matchedContactsArray = [[[ContactsModel sharedInstance] contactList] filteredArrayUsingPredicate:predicate];
    
    if(matchedContactsArray.count > 0) {
        PeppermintContact *peppermintContact = (PeppermintContact*)[matchedContactsArray firstObject];
        alternateCommunicationChannelAddress = peppermintContact.communicationChannelAddress;
        mailText = [NSString stringWithFormat:@"%@ %@",
                    LOC(@"via", @"via"), alternateCommunicationChannelAddress];
        
    }
    return mailText;
}

-(void) initDontAskAgainView {
    self.dontAskAgainView.layer.cornerRadius = 10;
    self.dontAskAgainView.layer.borderWidth = 2;
    self.dontAskAgainView.layer.borderColor = [UIColor peppermintGreen].CGColor;
    self.dontAskAgainView.backgroundColor = [UIColor clearColor];
    
    self.dontAskAgainImageView.hidden = !isUserConfirming;
    
    self.dontAskAgainLabel.textColor = [UIColor emptyResultTableViewCellHeaderLabelTextcolorGray];
    self.dontAskAgainLabel.font = [UIFont openSansSemiBoldFontOfSize:SIZE_SMALL];
    self.dontAskAgainLabel.text = LOC(@"Do not ask this again and always send the SMS message", @"message");
}

-(IBAction)dontAskAgainButtonPressed:(id)sender {
    self.dontAskAgainImageView.hidden = !self.dontAskAgainImageView.hidden;
}

-(void) initButtons {
    self.yesButton.backgroundColor      = self.noButton.backgroundColor     = [UIColor clearColor];
    self.yesButton.layer.borderColor    = self.noButton.layer.borderColor   = [UIColor blackColor].CGColor;
    [self.yesButton setTitle:LOC(@"Yes", @"Yes") forState:UIControlStateNormal];
    [self.noButton  setTitle:LOC(@"No", @"No") forState:UIControlStateNormal];
}

-(void) presentOverView:(UIView*) view forNameSurname:(NSString*)nameSurname {
    
    NSNumber *savedValue = defaults_object(DEFAULTS_DONT_SHOW_SMS_WARNING);
    isUserConfirming = savedValue && savedValue.boolValue;
    alternateCommunicationChannelAddress = nil;
    contactNameSurname = nameSurname;
    
    [self initMailText];
    [self initDontAskAgainView];
    
    if(isUserConfirming) {
        [self confirm:self.yesButton];
    } else {
        UIView *superView = view.superview;
        if(self.superview != superView) {
            [superView addSubview:self];
        }
        [superView bringSubviewToFront:self];
        self.frame = view.frame;
        [self setNeedsDisplay];
        self.hidden = NO;
    }
}

-(void) hideSMSChargeWarningView {
    self.hidden = YES;
}

-(IBAction)confirm:(id)sender {
    [self userAnswerReceived:YES];
}

-(IBAction)decline:(id)sender {
    [self userAnswerReceived:NO];
}

-(void) userAnswerReceived:(BOOL)confirm {
    [self hideSMSChargeWarningView];
    if(confirm) {
        isUserConfirming = !self.dontAskAgainImageView.hidden;
        defaults_set_object(DEFAULTS_DONT_SHOW_SMS_WARNING, [NSNumber numberWithBool:isUserConfirming]);
        [self.delegate userConfirmsToSendSMS];
    } else if([self.delegate respondsToSelector:@selector(userDeclinesToSendSMS)]) {
        [self.delegate userDeclinesToSendSMS];
    }
}

-(void) sendMessageToMailAddress {
    [self hideSMSChargeWarningView];
    [self.delegate sendMailInsteadOfSmsToRecepient:alternateCommunicationChannelAddress];
}

-(IBAction) sendViaEmailButtonPressed {
    if(alternateCommunicationChannelAddress.length > 0) {
        [self sendMessageToMailAddress];
    } else {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:LOC(@"Email", nil) message:contactNameSurname delegate:self cancelButtonTitle:LOC(@"Cancel", nil) otherButtonTitles:LOC(@"Save", nil), nil];
        alertView.alertViewStyle=UIAlertViewStylePlainTextInput;
        UITextField *textField = [alertView textFieldAtIndex:0];
        textField.text = @"";
        [alertView show];
    }
}


#pragma mark- UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([alertView.message isEqualToString:contactNameSurname]
       && ALERT_BUTTON_INDEX_OTHER_1 == buttonIndex) {
        NSString *email = [[alertView textFieldAtIndex:0] text];
        if([email isValidEmail]) {
            alternateCommunicationChannelAddress = email;
            [self sendMessageToMailAddress];
        }
    }
}

@end
