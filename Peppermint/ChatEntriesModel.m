//
//  ChatEntriesModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 22/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatEntriesModel.h"
#import "Repository.h"

@interface ChatEntriesModel()
@property (strong, nonatomic) Repository *repository;

@end

@implementation ChatEntriesModel

-(id) initWithChat:(Chat*) chat {
    self = [super init];
    if(self) {
        self.repository = [Repository beginTransaction];
        _chatEntriesArray = [NSArray new];
        self.chat =  (Chat*)[self.repository objectWithURI:chat.objectID.URIRepresentation];
        
        NSPredicate *chatPredicate = [NSPredicate predicateWithFormat:@"self.chat = %@", self.chat];
        _chatEntriesArray = [self.repository getResultsFromEntity:[ChatEntry class] predicateOrNil:chatPredicate ascSortStringOrNil:[NSArray arrayWithObjects:@"dateCreated", nil] descSortStringOrNil:nil];
        
    }
    return self;
}

- (void) dealloc {
    NSError *error = [self.repository endTransaction];
    if(error) {
        [self.delegate operationFailure:error];
    }
}

@end
