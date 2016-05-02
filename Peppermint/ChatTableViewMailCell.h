//
//  ChatTableViewMailCell.h
//  Peppermint
//
//  Created by Okan Kurtulus on 24/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatTableViewBaseCell.h"
@class PeppermintChatEntry;
@class ChatEntryModel;

@interface ChatTableViewMailCell : ChatTableViewBaseCell

@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *mailContentLabel;


@property (strong, nonatomic, readonly) PeppermintChatEntry *peppermintChatEntry;

@property (strong, nonatomic, readonly) ChatEntryModel *chatEntryModel;
- (void) fillInformation:(PeppermintChatEntry*) chatEntry;
- (void) resetContent;

@end
