//
//  UidHolder.h
//  Peppermint
//
//  Created by Okan Kurtulus on 23/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"

@interface UidHolder : JSONModel
@property (strong, nonatomic) NSMutableDictionary<Optional> *accountsUdidDictionary;
@end
