//
//  AddContactViewController.h
//  Peppermint
//
//  Created by Yan Saraev on 11/26/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomContactModel.h"
#import "BaseTableViewController.h"

@protocol AddContactViewControllerDelegate <NSObject>
-(void) nameFieldUpdated:(NSString*)name;
@end

@interface AddContactViewController : BaseTableViewController
@property (weak, nonatomic) id<AddContactViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField * firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField * lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField * countryCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField * phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField * emailTextField;
@property (weak, nonatomic) IBOutlet UIImageView * flagImageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveContactBarButtonItem;
@property (weak, nonatomic) IBOutlet UILabel *explanationLabel;

+ (void)presentAddContactControllerWithText:(NSString*) text withDelegate:(id<AddContactViewControllerDelegate>) delegate;
@end
