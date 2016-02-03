//
//  Data.h
//  Peppermint
//
//  Created by Okan Kurtulus on 02/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"
#import "Attribute.h"

#define TYPE_RECORDERS                  @"recorders"
#define TYPE_MESSAGES                   @"messages"

@protocol Data
@end

@interface Data : JSONModel
@property (strong, nonatomic) NSString<Optional> *id;
@property (strong, nonatomic) NSString<Optional> *type;
@property (strong, nonatomic) Attribute<Optional> *attributes;
@end
