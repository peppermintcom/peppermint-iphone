//
//  SMSChargeWarningView.h
//  Peppermint
//
//  Created by Okan Kurtulus on 04/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseCustomView.h"

@protocol SMSChargeWarningViewDelegate <NSObject>
@required
- (void) userConfirmsToSendSMS;
- (void) sendMailInsteadOfSmsToRecepient:(NSString*) email;
@optional
- (void) userDeclinesToSendSMS;
@end

@interface SMSChargeWarningView : BaseCustomView

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *sendViaEmailLabel;
@property (weak, nonatomic) IBOutlet UIView         *dontAskAgainView;
@property (weak, nonatomic) IBOutlet UIImageView    *dontAskAgainImageView;
@property (weak, nonatomic) IBOutlet UILabel        *dontAskAgainLabel;
@property (weak, nonatomic) IBOutlet UIButton *noButton;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) id<SMSChargeWarningViewDelegate> delegate;

+(SMSChargeWarningView*) createInstanceWithDelegate:(id<SMSChargeWarningViewDelegate>) delegate;
-(void) presentOverView:(UIView*) view forNameSurname:(NSString*)nameSurname;

@end
