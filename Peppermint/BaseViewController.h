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

#define ALERT_BUTTON_INDEX_CANCEL   0
#define ALERT_BUTTON_INDEX_OTHER_1  1
#define ALERT_BUTTON_INDEX_OTHER_2  2
#define ALERT_BUTTON_INDEX_OTHER_3  3

@interface BaseViewController : UIViewController <BaseModelDelegate>
-(void) redirectToSettingsPageForPermission;
@end
