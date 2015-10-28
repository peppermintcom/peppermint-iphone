//
//  ReSideMenuContainerViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 28/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "RESideMenu.h"
#import "ContactsModel.h"
#import "FeedBackModel.h"

@interface ReSideMenuContainerViewController : RESideMenu <FeedBackModelDelegate>
-(void) initContactsViewControllerWithContactsModel:(ContactsModel*) contactsModel;
-(void) sendFeedback;
@end
