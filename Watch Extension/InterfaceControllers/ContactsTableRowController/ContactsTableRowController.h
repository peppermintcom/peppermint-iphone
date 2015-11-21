//
//  ContactsTableRowController.h
//  Peppermint
//
//  Created by Yan Saraev on 11/20/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>

@import WatchKit;

@interface ContactsTableRowController : NSObject

@property (weak, nonatomic) IBOutlet WKInterfaceLabel * titleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel * subtitleLabel;

@end
