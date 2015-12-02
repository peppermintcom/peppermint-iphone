//
//  AddContactViewController.h
//  Peppermint
//
//  Created by Yan Saraev on 11/26/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddContactViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField * firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField * lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField * countryCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField * phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField * emailTextField;
@property (weak, nonatomic) IBOutlet UIImageView * flagImageView;

+ (void)presentAddContactControllerWithCompletion:(void (^)())completion;

@end
