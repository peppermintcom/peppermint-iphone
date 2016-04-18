//
//  SparkPostRequest.m
//  Peppermint
//
//  Created by Okan Kurtulus on 18/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "SparkPostRequest.h"

@implementation SparkPostRequest

-(id) init {
    self = [super init];
    if(self) {
        self.recipients = (NSMutableArray<SparkPostRecipient*>*)[NSMutableArray new];
    }
    return self;
}

-(NSDictionary*) toDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    NSArray* recipientObjects = [SparkPostRecipient arrayOfDictionariesFromModels:self.recipients];
    [dictionary setValue:recipientObjects forKey:@"recipients"];
    return dictionary;
}

@end