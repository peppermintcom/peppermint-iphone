//
//  MandrillNameContentPair.h
//  Peppermint
//
//  Created by Okan Kurtulus on 18/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"

@protocol MandrillNameContentPair
@end

@interface MandrillNameContentPair : JSONModel
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* content;
+(instancetype) createWithName:(NSString*)name content:(NSString*) content;
@end
