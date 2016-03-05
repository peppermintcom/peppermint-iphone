//
//  MessageGetRequest.h
//  Peppermint
//
//  Created by Okan Kurtulus on 29/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"

@interface MessageGetRequest : JSONModel

@property (strong, nonatomic) NSString<Optional>* recipient;
@property (strong, nonatomic) NSString<Optional>* sender;
@property (strong, nonatomic) NSString<Optional>* since;

-(void) setSinceDate:(NSDate*) sinceDate;

@end
