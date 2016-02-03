//
//  Data.m
//  Peppermint
//
//  Created by Okan Kurtulus on 02/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "Data.h"

@implementation Data

-(NSDictionary*) toDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    [dictionary setValue:[self.attributes toDictionary] forKey:@"attributes"];
    return dictionary;
}

@end
