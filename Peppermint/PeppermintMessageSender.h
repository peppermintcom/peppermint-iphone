//
//  PeppermintMessageSender.h
//  Peppermint
//
//  Created by Okan Kurtulus on 20/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PeppermintMessageSender : NSObject
@property (strong, nonatomic) NSString *nameSurname;
@property (strong, nonatomic) NSString *email;

-(void) save;
-(BOOL) isValid;

@end