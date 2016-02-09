//
//  ChatsViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 15/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"
#import "ChatModel.h"

@interface ChatsViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, ChatModelDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView     *chatsEmptyView;
@property (weak, nonatomic) IBOutlet UILabel    *informationLabel;
@property (weak, nonatomic) IBOutlet UILabel    *goBackAndSendMessageLabel;


+(instancetype) createInstance;
-(void) scheduleNavigateToChatEntryWithEmail:(NSString*) email nameSurname:(NSString*)nameSurname;
-(void) refreshContent;

@end
