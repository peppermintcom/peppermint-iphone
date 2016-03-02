//
//  MessageGetResponse.h
//  Peppermint
//
//  Created by Okan Kurtulus on 29/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"
#import "Data.h"
#import "Link.h"

@interface MessageGetResponse : JSONModel
@property (strong, nonatomic) NSArray<Data> *data;
@property (strong, nonatomic) Link<Optional> *links;
@end
