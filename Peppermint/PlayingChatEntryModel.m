//
//  PlayingChatEntryModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 25/03/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "PlayingChatEntryModel.h"
#import "PlayingModel.h"
#import "PeppermintChatEntry.h"

@implementation PlayingChatEntryModel {
    PeppermintChatEntry *cachedPeppermintChatEntry;
    PlayingModel *cachedPlayingModel;
}

+ (instancetype) sharedInstance {
    return SHARED_INSTANCE( [[self alloc] initShared] );
}

-(id) init {
    NSAssert(false, @"This model instance is singleton so should not be inited - %@", self);
    return nil;
}

-(id) initShared {
    self = [super init];
    if(self) {
        cachedPlayingModel = nil;
        cachedPeppermintChatEntry = nil;
    }
    return self;
}

-(PlayingModel*) playModelForChatEntry:(PeppermintChatEntry*) peppermintChatEntry {
    PlayingModel *playingModel = nil;
    if(cachedPlayingModel
       && [peppermintChatEntry isEqual:cachedPeppermintChatEntry]
       && peppermintChatEntry.audio
       && [cachedPlayingModel.audioPlayer.data isEqual:peppermintChatEntry.audio]) {
        playingModel = cachedPlayingModel;
    }
    return playingModel;
}

-(void) cachePlayingModel:(PlayingModel*)playingModel forChatEntry:(PeppermintChatEntry*) peppermintChatEntry {
    [cachedPlayingModel stop];
    cachedPeppermintChatEntry = peppermintChatEntry;
    cachedPlayingModel = playingModel;
}

SUBSCRIBE(StopAllPlayingMessages) {
    if(cachedPlayingModel) {
        [cachedPlayingModel.audioPlayer stop];
        cachedPlayingModel = nil;
    }
}

@end
