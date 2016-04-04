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
        _cachedPlayingModel = nil;
        cachedPeppermintChatEntry = nil;
    }
    return self;
}

-(PlayingModel*) playModelForChatEntry:(PeppermintChatEntry*) peppermintChatEntry {
    PlayingModel *playingModel = nil;
    if(self.cachedPlayingModel
       && [peppermintChatEntry isEqual:cachedPeppermintChatEntry]
       && peppermintChatEntry.audio
       && [self.cachedPlayingModel.audioPlayer.data isEqual:peppermintChatEntry.audio]) {
        playingModel = self.cachedPlayingModel;
    }
    return playingModel;
}

-(void) cachePlayingModel:(PlayingModel*)playingModel forChatEntry:(PeppermintChatEntry*) peppermintChatEntry {
    [_cachedPlayingModel stop];
    cachedPeppermintChatEntry = peppermintChatEntry;
    _cachedPlayingModel = playingModel;
}

SUBSCRIBE(StopAllPlayingMessages) {
    if(self.cachedPlayingModel) {
        [self.cachedPlayingModel.audioPlayer stop];
        _cachedPlayingModel = nil;
    }
}

@end
