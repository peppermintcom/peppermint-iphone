//
//  MandrillNameContentPair.m
//  Peppermint
//
//  Created by Okan Kurtulus on 18/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "MandrillNameContentPair.h"

@implementation MandrillNameContentPair

+(instancetype) createWithName:(NSString*)name content:(NSString*) content {
    MandrillNameContentPair *mandrillNameContentPair = [MandrillNameContentPair new];
    mandrillNameContentPair.name = name;
    mandrillNameContentPair.content = content;
    return mandrillNameContentPair;
}

@end
