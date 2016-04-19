//
//  SparkPostContent.h
//  Peppermint
//
//  Created by Okan Kurtulus on 18/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"
#import "SparkPostFrom.h"

@interface SparkPostContent : JSONModel
@property (strong, nonatomic) NSString<Optional> *html;
@property (strong, nonatomic) NSString<Optional> *text;
@property (strong, nonatomic) NSString<Optional> *subject;
@property (strong, nonatomic) NSString<Optional> *reply_to;
@property (strong, nonatomic) SparkPostFrom<Optional> *from;
@end
