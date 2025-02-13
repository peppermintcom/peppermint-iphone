//
//  BaseViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellFactory.h"
#import "BaseModel.h"
#import "MBProgressHUD.h"
#import "JPAttributedString.h"
#import "GAITrackedViewController.h"

@interface BaseViewController : GAITrackedViewController <BaseModelDelegate>
-(void) redirectToSettingsPageForPermission;

-(BOOL) checkIfuserIsLoggedIn;
@end
