//
//  ChatTableViewMailCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 24/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatTableViewMailCell.h"
#import "PeppermintChatEntry.h"
#import "ChatEntryModel.h"

@implementation ChatTableViewMailCell 

- (void)awakeFromNib {
    [super awakeFromNib];
    _chatEntryModel = [ChatEntryModel new];
    _chatEntryModel.delegate = nil;
    
    self.subjectLabel.textColor = [UIColor emailLoginColor];
    self.subjectLabel.font = [UIFont openSansSemiBoldFontOfSize:15];
    
}

- (void) fillInformation:(PeppermintChatEntry*) chatEntry {
    _peppermintChatEntry = chatEntry;
    self.subjectLabel.text = chatEntry.subject;
    self.mailContentLabel.text = chatEntry.mailContent.length > 0 ? chatEntry.mailContent : @" ";
    
    chatEntry.isSeen = YES;
    [self.chatEntryModel savePeppermintChatEntry:chatEntry];
}

- (IBAction)touchDown:(id)sender {
    NSLog(@"touched..");
    self.contentView.backgroundColor = self.tableView.backgroundColor;
}

-(BOOL) isSentByMe {
    return _peppermintChatEntry.isSentByMe;
}

@end
