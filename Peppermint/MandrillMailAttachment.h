//
//  MandrillMailAttachment.h
//  Peppermint
//
//  Created by Okan Kurtulus on 18/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"

@protocol MandrillMailAttachment
@end

@interface MandrillMailAttachment : JSONModel
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *content;
@end
