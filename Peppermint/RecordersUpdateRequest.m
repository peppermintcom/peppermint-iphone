//
//  RecordersUpdateRequest.m
//  Peppermint
//
//  Created by Okan Kurtulus on 02/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "RecordersUpdateRequest.h"

@implementation RecordersUpdateRequest

-(NSDictionary*) toDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    [dictionary setValue:[self.data toDictionary] forKey:@"data"];
    return dictionary;
}

@end
