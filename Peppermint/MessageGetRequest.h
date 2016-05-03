//
//  MessageGetRequest.h
//  Peppermint
//
//  Created by Okan Kurtulus on 29/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"

#define ORDER_REVERSE       @"reverse"
#define ORDER_CHRONOLOGICAL @"chronological"

@interface MessageGetRequest : JSONModel

@property (strong, nonatomic) NSString<Optional>* recipient;
@property (strong, nonatomic) NSString<Optional>* sender;
@property (strong, nonatomic) NSString<Optional>* since;
@property (strong, nonatomic) NSString<Optional>* until;
@property (strong, nonatomic) NSString<Optional>* order;

-(void) setSinceDate:(NSDate*) sinceDate;
-(void) setUntilDate:(NSDate*) untilDate;

@end
