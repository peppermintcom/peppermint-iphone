//
//  Attribute.h
//  Peppermint
//
//  Created by Okan Kurtulus on 01/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"
@class PeppermintChatEntry;

@interface Attribute : JSONModel
@property (strong, nonatomic) NSString<Optional> *gcm_registration_token;
@property (strong, nonatomic) NSString<Optional> *token;

@property (strong, nonatomic) NSString<Optional> *transcription_url;
@property (strong, nonatomic) NSString<Optional> *audio_url;
@property (strong, nonatomic) NSString<Optional> *sender_email;
@property (strong, nonatomic) NSString<Optional> *recipient_email;
@property (strong, nonatomic) NSString<Optional> *sender_name;
@property (strong, nonatomic) NSString<Optional> *created;
@property (strong, nonatomic) NSNumber<Optional> *duration;
@property (strong, nonatomic) NSString<Optional> *message_id;
@property (strong, nonatomic) NSString<Optional> *read;

-(NSDate*) createdDate;

@end