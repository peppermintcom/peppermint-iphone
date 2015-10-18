//
//  MandrillMessage.h
//  Peppermint
//
//  Created by Okan Kurtulus on 18/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"
#import "MandrillToObject.h"
#import "MandrillMailAttachment.h"

@interface MandrillMessage : JSONModel
@property (strong, nonatomic) NSString *html;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *from_email;
@property (strong, nonatomic) NSString *from_name;
@property (strong, nonatomic) NSMutableArray<MandrillToObject>*  to;
@property (strong, nonatomic) NSMutableDictionary *headers;
@property (strong, nonatomic) NSMutableArray *tags;
@property (strong, nonatomic) NSMutableArray<MandrillMailAttachment> *attachments;

@end