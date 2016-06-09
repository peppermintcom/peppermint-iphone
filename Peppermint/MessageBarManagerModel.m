//
//  MessageBarManagerModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 12/05/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "MessageBarManagerModel.h"
#import "TWMessageBarManager.h"

#define EMOJI_MICROPHONE    @"\U0001F3A4"

@interface MessageBarManagerModel() <TWMessageBarStyleSheet>

@end

@implementation MessageBarManagerModel

-(id) init {
    self = [super init];
    if(self) {
        [TWMessageBarManager sharedInstance].styleSheet = self;
    }
    return self;
}

-(void) triggerMessageWithPressedCallBack:(nullable void (^)())callback {
    BOOL isMessageSet = (self.messageTitle.length > 0 && self.messageBody.length > 0);
    if(isMessageSet) {
        NSString *description = [NSString stringWithFormat:@"%@ %@",EMOJI_MICROPHONE, self.messageBody.normalizeText];
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:self.nameSurname.capitalizedString.normalizeText
                                                       description:description
                                                              type:TWMessageBarMessageTypeSuccess
                                                          callback:^{
                                                              callback();
                                                              NSLog(@"Call back is called... :)");
                                                          }];
    }
    [self clearCache];
}

-(void) clearCache {
    self.messageTitle = nil;
    self.messageBody = nil;
    self.avatarImage = nil;
}

#pragma mark - TWMessageBarStyleSheet

- (nonnull UIColor *)backgroundColorForMessageType:(TWMessageBarMessageType)type {
    return [UIColor blackColor];
}

- (nonnull UIColor *)strokeColorForMessageType:(TWMessageBarMessageType)type {
    return [UIColor blackColor];
}

- (nonnull UIImage *)iconImageForMessageType:(TWMessageBarMessageType)type {
    if(!self.avatarImage) {
        self.avatarImage = [UIImage imageNamed:@"avatar_empty"];
    }
    return self.avatarImage;
}

@end
