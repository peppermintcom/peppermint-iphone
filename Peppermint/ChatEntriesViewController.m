//
//  ChatEntriesViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 19/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatEntriesViewController.h"
#import "SendVoiceMessageMandrillModel.h"
#import "RecordingGestureButton.h"
#import "ChatModel.h"
#import "FoggyRecordingView.h"
#import "SendVoiceMessageSMSModel.h"
#import "AutoPlayModel.h"

@interface ChatEntriesViewController () <RecordingGestureButtonDelegate, ChatModelDelegate, RecordingViewDelegate>

@end

@implementation ChatEntriesViewController {
    NSTimer *holdToRecordViewTimer;
    AutoPlayModel *autoPlayModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = CELL_HEIGHT_CHAT_TABLEVIEWCELL;
    
    self.tableView.backgroundColor = [UIColor slideMenuTableViewColor];
    self.bottomInformationLabel.font = [UIFont openSansSemiBoldFontOfSize:18];
    self.bottomInformationLabel.textColor = [UIColor textFieldTintGreen];
    self.bottomInformationLabel.backgroundColor = [UIColor peppermintGray248];
    self.bottomInformationLabel.layer.borderWidth = 1;
    self.bottomInformationLabel.layer.borderColor = [UIColor cellSeperatorGray].CGColor;
    self.bottomInformationLabel.text = LOC(@"Record a Message", @"Record a Message");
    
    self.avatarImageView.layer.cornerRadius = 5;
    self.holdToRecordView.hidden = YES;
    self.holdToRecordLabel.font = [UIFont openSansSemiBoldFontOfSize:15];
    self.holdToRecordLabel.textColor = [UIColor whiteColor];
    self.holdToRecordLabel.text = LOC(@"Hold to record message", @"Hold to record message");
    
    [self.holdToRecordView addGestureRecognizer:
     [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(hideHoldToRecordInfoView)]];
    [self.holdToRecordView addGestureRecognizer:
     [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideHoldToRecordInfoView)]];
    [self.holdToRecordView addGestureRecognizer:
     [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideHoldToRecordInfoView)]];
    autoPlayModel =[AutoPlayModel sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSParameterAssert(self.chatModel);
    self.chatModel.delegate = self;
    
    Chat *chat = self.chatModel.selectedChat;
    if(chat.avatarImageData) {
        CGRect frame = self.avatarImageView.frame;
        int width = frame.size.width;
        int height = frame.size.height;
        self.avatarImageView.image = [[UIImage imageWithData:chat.avatarImageData] resizedImageWithWidth:width height:height];
    }
    [self setTitleText];
}

-(void) setTitleText {
    Chat *chat = self.chatModel.selectedChat;
    CGFloat width = SCREEN_WIDTH - 90; //self.titleLabel.frame.size.width - 20;
    CGFloat height = 23; // self.titleLabel.frame.size.height;
    
    NSString *nameSurname = [chat.nameSurname limitToFitInWidth:width height:height andFonttSize:17];
    NSString *communicationChannelAddress = [chat.communicationChannelAddress limitToFitInWidth:width height:height andFonttSize:13];
    
    NSMutableAttributedString *attrText = [NSMutableAttributedString new];
    [attrText addText:nameSurname ofSize:17 ofColor:[UIColor whiteColor] andFont:[UIFont openSansSemiBoldFontOfSize:17]];
    [attrText addText:@"\n" ofSize:12 ofColor:[UIColor clearColor]];
    [attrText addText:communicationChannelAddress ofSize:13 ofColor:[UIColor recordingNavigationsubTitleGreen]];
    [attrText centerText];
    self.titleLabel.attributedText = attrText;
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [self.chatModel refreshChatEntries];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initRecordingViewWithView:self.recordingButton];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.chatModel = nil;
    self.recordingView = nil;
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.recordingView = nil;
    
    BOOL isScheduledForCurrentVC = [autoPlayModel isScheduledForPeppermintContactWithEmail:self.chatModel.selectedChat.communicationChannelAddress];
    if(isScheduledForCurrentVC) {
        [autoPlayModel clearScheduledPeppermintContact];
    }
    
#warning "What if the playing cell is not currently visible. Have further test and fix issue!"
    for(ChatTableViewCell* cell in [self.tableView visibleCells]) {
        [cell.playingModel.audioPlayer stop];
    }
}

#pragma mark - ChatModelDelegate

-(void) chatEntriesArrayIsUpdated {
    [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
    [self navigateToLastRow];
    
#warning "Added a latency for checking auto-play. Please investigate if we need this latency or not"
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self checkForAutoPlay];
    });
}

-(void) navigateToLastRow {
    [self.tableView reloadData];
    NSUInteger lastSection = 0;
    NSUInteger lastRowNumber = [self.tableView numberOfRowsInSection:lastSection] - 1;
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:lastRowNumber inSection:lastSection];
    
    if(indexPath.row >= 0 && indexPath.section >= 0) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
    
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = [self.chatModel.chatEntriesArray count];
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ChatTableViewCell *cell = [CellFactory cellChatTableViewCellFromTable:tableView forIndexPath:indexPath];    
    ChatEntry *chatEntry = (ChatEntry*)[self.chatModel.chatEntriesArray objectAtIndex:indexPath.row];
    [cell fillInformation:chatEntry];    
    cell.contentView.backgroundColor = self.tableView.backgroundColor;
    return cell;
}

#pragma mark - Back button

-(IBAction) backButtonTouchDown:(id)sender {
    UIButton *menuButton = (UIButton*)sender;
    menuButton.alpha = 0.7;
}

-(IBAction) backButtonTouchUp:(id)sender {
    UIButton *menuButton = (UIButton*)sender;
    menuButton.alpha = 1;
}

-(IBAction) backButtonValidAction:(id)sender {
    [self backButtonTouchUp:sender];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - RecordingView Settings

-(void) initRecordingViewWithView:(UIControl*) control {
    self.recordingButton.delegate = self;
    self.recordingView = [FoggyRecordingView createInstanceWithDelegate:self];
    CGRect rect = self.view.frame;
    
    self.recordingView.frame = rect;
    [self.view addSubview:self.recordingView];
    [self.view bringSubviewToFront:self.recordingView];
    
    FoggyRecordingView *foggyRecordingView = (FoggyRecordingView*)self.recordingView;
    if(foggyRecordingView) {
        foggyRecordingView.swipeInAnyDirectionView.hidden = YES;
        CGRect frame = foggyRecordingView.microphoneImageView.frame;
        foggyRecordingView.microphoneViewRightOffsetConstraint.constant =  -1 * (frame.size.width * 0.2);
        foggyRecordingView.microphoneViewCenterYConstraint.constant = -1 * (frame.size.height * 0.1);
    }
};


#pragma mark - RecordingGestureButtonDelegate

-(void) touchDownBeginOnIndexPath:(id) sender event:(UIEvent *)event {
    NSLog(@"touchDownBeginOnIndexPath");
}

-(void) touchHoldSuccessOnLocation:(CGPoint) touchBeginPoint {
    PeppermintContact *peppermintContact = [PeppermintContact new];
    peppermintContact.nameSurname = self.chatModel.selectedChat.nameSurname;
    peppermintContact.communicationChannel = self.chatModel.selectedChat.communicationChannel.intValue;
    peppermintContact.communicationChannelAddress = self.chatModel.selectedChat.communicationChannelAddress;
    
    SendVoiceMessageModel *sendVoiceMessageModel = nil;
    if(peppermintContact.communicationChannel == CommunicationChannelEmail) {
        sendVoiceMessageModel = [SendVoiceMessageMandrillModel new];
    } else if (peppermintContact.communicationChannel == CommunicationChannelSMS) {
        sendVoiceMessageModel = [SendVoiceMessageSMSModel new];
    }
    
    sendVoiceMessageModel.selectedPeppermintContact = peppermintContact;
    self.recordingView.sendVoiceMessageModel = sendVoiceMessageModel;
    
    CGRect rect = self.recordingButton.frame;
    [self.recordingView presentWithAnimationInRect:rect onPoint:CGPointMake(0, 0)];
}

-(void) touchSwipeActionOccuredOnLocation:(CGPoint) location {
    [self.recordingView finishRecordingWithGestureIsValid:NO];
}

-(void) touchShortTapActionOccuredOnLocation:(CGPoint) location {
    [holdToRecordViewTimer invalidate];
    holdToRecordViewTimer = nil;
    if(self.holdToRecordView.hidden) {
        self.holdToRecordView.alpha = 0;
        self.holdToRecordView.hidden = NO;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.holdToRecordView.alpha = 1;
    } completion:^(BOOL finished) {
        holdToRecordViewTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hideHoldToRecordInfoView) userInfo:nil repeats:NO];
    }];
}

-(void) touchCompletedAsExpectedWithSuccessOnLocation:(CGPoint) location {
    [self.recordingView finishRecordingWithGestureIsValid:YES];
}

-(void) touchDownCancelledWithEvent:(UIEvent *)event {
    [self.recordingView finishRecordingWithGestureIsValid:NO];
}

#pragma mark - RecordingViewDelegate

-(void) recordingViewDissappeared {
    NSLog(@"recordingViewDissappeared");
}

-(void) message:(NSString*) message isUpdatedWithStatus:(SendingStatus) sendingStatus cancelAble:(BOOL)isCacnelAble {
    NSLog(@"message:isUpdatedWithStatus:cancelable:");
}

-(void) newRecentContactisSaved {
    NSLog(@"newRecentContactisSaved");
}

-(void) chatHistoryCreatedWithSuccess {
    NSLog(@"chatHistoryCreatedWithSuccess");
    [self.chatModel refreshChatEntries];
}

#pragma mark - HoldToRecordView

-(void) hideHoldToRecordInfoView {
    [holdToRecordViewTimer invalidate];
    holdToRecordViewTimer = nil;
    [UIView animateWithDuration:ANIM_TIME animations:^{
        self.holdToRecordView.alpha = 0;
    } completion:^(BOOL finished) {
        self.holdToRecordView.hidden = YES;
    }];
}

#pragma mark - Refresh Content

-(void) refreshContent {
    [self.chatModel refreshChatEntries];
}

#pragma mark - AutoPlay

-(void) checkForAutoPlay {
    NSString *email = self.chatModel.selectedChat.communicationChannelAddress;
    BOOL isAutoPlayScheduled = [autoPlayModel isScheduledForPeppermintContactWithEmail:email];
    if(isAutoPlayScheduled) {
        [[AppDelegate Instance] hideAppCoverLoadingView];
        NSUInteger lastSection = 0;
        NSUInteger lastRowNumber = [self.tableView numberOfRowsInSection:lastSection] - 1;
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:lastRowNumber inSection:lastSection];
        ChatTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell playPauseButtonPressed:nil];
    }
}

@end
