//
//  PeppermintMessageSender.h
//  Peppermint
//
//  Created by Okan Kurtulus on 20/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

typedef enum : NSUInteger {
    LOGINSOURCE_FACEBOOK,
    LOGINSOURCE_GOOGLE,
    LOGINSOURCE_PEPPERMINT,
} LoginSource;

#warning "Implement save and load with json instead of ns user defaults!"
@interface PeppermintMessageSender : JSONModel
@property (strong, nonatomic) NSString *nameSurname;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSData *imageData;
@property (nonatomic) LoginSource loginSource;

-(void) save;
-(BOOL) isValid;

@end