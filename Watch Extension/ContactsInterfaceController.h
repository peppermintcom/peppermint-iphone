//
//  InterfaceController.h
//  Watch Extension
//
//  Created by Yan Saraev on 11/18/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface ContactsInterfaceController : WKInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceButton * searchButton;
@property (weak, nonatomic) IBOutlet WKInterfaceTable * tableView;


@end
