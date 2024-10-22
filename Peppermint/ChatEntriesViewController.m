//
//  ChatEntriesViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 19/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatEntriesViewController.h"
#import "SendVoiceMessageSparkPostModel.h"
#import "RecordingGestureButton.h"
#import "FoggyRecordingView.h"
#import "SendVoiceMessageSMSModel.h"
#import "AutoPlayModel.h"
#import "PeppermintContact.h"
#import "ProximitySensorModel.h"
#import "ChatEntrySyncModel.h"

#define BOTTOM_RESET_IME            2
#define WAIT_FOR_SHAKE_DURATION     2

@interface ChatEntriesViewController () <RecordingGestureButtonDelegate, RecordingViewDelegate>
@end

@implementation ChatEntriesViewController {
    __block BOOL scheduleRefresh;
    BOOL isScrolling;
    __block BOOL isPlaying;
    NSTimer *recordingPausedTimer;
    NSMutableDictionary *calculatedHeightsDictionary;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isScrolling = NO;
    isPlaying = NO;
    recordingPausedTimer = nil;
    
    [self resetBottomInformationLabel];
    
    self.avatarImageView.layer.cornerRadius = 5;
    
    [self recordingView]; // init recording view to be able to handle status change events
    self.recordingButton.delegate = self;
    calculatedHeightsDictionary = [NSMutableDictionary new];
    REGISTER();
}

-(void) resetBottomInformationLabel {
    self.bottomInformationFullLabel.backgroundColor = [UIColor peppermintGray248];
    self.bottomInformationFullLabel.layer.borderWidth = 1;
    self.bottomInformationFullLabel.layer.borderColor = [UIColor cellSeperatorGray].CGColor;
    self.bottomInformationFullLabel.font = [UIFont openSansSemiBoldFontOfSize:18];
    self.bottomInformationFullLabel.textColor = [UIColor textFieldTintGreen];
    self.bottomInformationFullLabel.text = @"";
    
    self.tableView.backgroundColor = [UIColor slideMenuTableViewColor];
    self.bottomInformationLabel.font = [UIFont openSansSemiBoldFontOfSize:18];
    self.bottomInformationLabel.textColor = [UIColor textFieldTintGreen];
    self.bottomInformationLabel.text = LOC(@"Record a Message", @"Record a Message");
    self.microphoneView.hidden = self.bottomInformationLabel.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkToTakeOverSendingMessageEvents];
    NSParameterAssert(self.peppermintContact);
    scheduleRefresh = NO;
    if(self.peppermintContact.avatarImage) {
        CGRect frame = self.avatarImageView.frame;
        int width = frame.size.width;
        int height = frame.size.height;
        self.avatarImageView.image = [self.peppermintContact.avatarImage resizedImageWithWidth:width height:height];
    }
    [self setTitleText];
}

-(void) setTitleText {

    CGFloat width = SCREEN_WIDTH - 90; //self.titleLabel.frame.size.width - 20;
    CGFloat height = 23; // self.titleLabel.frame.size.height;
    
    NSString *nameSurname = [self.peppermintContact.nameSurname limitToFitInWidth:width height:height andFonttSize:17];
    NSString *communicationChannelAddress = [self.peppermintContact.communicationChannelAddress limitToFitInWidth:width height:height andFonttSize:13];
    
    NSMutableAttributedString *attrText = [NSMutableAttributedString new];
    [attrText addText:nameSurname ofSize:17 ofColor:[UIColor whiteColor] andFont:[UIFont openSansSemiBoldFontOfSize:17]];
    [attrText addText:@"\n" ofSize:12 ofColor:[UIColor clearColor]];
    [attrText addText:communicationChannelAddress ofSize:13 ofColor:[UIColor recordingNavigationsubTitleGreen]];
    [attrText centerText];
    self.titleLabel.attributedText = attrText;
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startListeningProximitySensor];
    [self refreshContent];
    if(self.chatEntryTypesToShow == ChatEntryTypeNone) {
        NSLog(@"No ChatEntryTypes are set to be shown. View content will be empty!!");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    _chatEntryModel = nil;
    if(_recordingView.hidden) {
        _recordingView = nil;
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.recordingView = nil;
    [self fireStopPlayingMessage];
    [self stopListeningProximitySensor];
}

-(void) fireStopPlayingMessage {
    StopAllPlayingMessages *stopAllPlayingMessages = [StopAllPlayingMessages new];
    stopAllPlayingMessages.sender = self;
    PUBLISH(stopAllPlayingMessages);
}

-(void) checkToTakeOverSendingMessageEvents {
    SendVoiceMessageModel *sendVoiceMessageModel = [SendVoiceMessageModel activeSendVoiceMessageModel];
    BOOL isSendingStateOKToTakeOver = (sendVoiceMessageModel.sendingStatus == SendingStatusStarting
                                       || sendVoiceMessageModel.sendingStatus == SendingStatusUploading
                                       || sendVoiceMessageModel.sendingStatus == SendingStatusSending
                                       || sendVoiceMessageModel.sendingStatus == SendingStatusSendingWithNoCancelOption);
    
    if(sendVoiceMessageModel
       && [sendVoiceMessageModel.selectedPeppermintContact isEqual:self.peppermintContact]
       && isSendingStateOKToTakeOver ) {
        [self messageModel:sendVoiceMessageModel isUpdatedWithStatus:sendVoiceMessageModel.sendingStatus cancelAble:sendVoiceMessageModel.isCancelAble];
    } else {
        NSLog(@"SendVoiceMessageModel is not active to take over sending process.");
        [self resetBottomInformationLabel];
    }
}

#pragma mark - ChatEntryModelDelegate

-(void) peppermintChatEntriesArrayIsUpdated {
    [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
    [self navigateToLastRow];
    [self checkForAutoPlay];
}

-(void) peppermintChatEntrySavedWithSuccess:(NSArray*) savedPeppermintChatEnryArray {
    NSLog(@"peppermintChatEntrySavedWithSuccess");
}

-(void) lastMessagesAreUpdated:(NSArray<PeppermintContactWithChatEntry *> *)peppermintContactWithChatEntryArray {
    NSLog(@"lastMessagesAreUpdated:");
}

#pragma mark - UITableView

-(void) navigateToLastRow {
    [self.tableView reloadData];
    NSUInteger lastSection = 0;
    NSUInteger lastRowNumber = [self.tableView numberOfRowsInSection:lastSection] - 1;
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:lastRowNumber inSection:lastSection];
    
    if(indexPath.row >= 0 && indexPath.section >= 0) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = [self.chatEntryModel.chatEntriesArray count];
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if(self.chatEntryModel.chatEntriesArray.count > indexPath.row) {
        PeppermintChatEntry *peppermintChatEntry = (PeppermintChatEntry*)[self.chatEntryModel.chatEntriesArray objectAtIndex:indexPath.row];
        
        if(peppermintChatEntry.type == ChatEntryTypeAudio) {
            ChatTableViewCell *chatTableViewCell = [CellFactory cellChatTableViewCellFromTable:tableView forIndexPath:indexPath andDelegate:self];
            [chatTableViewCell fillInformation:peppermintChatEntry];
            chatTableViewCell.contentView.backgroundColor = self.tableView.backgroundColor;
            cell = chatTableViewCell;
        } else if (peppermintChatEntry.type == ChatEntryTypeEmail) {
            ChatTableViewMailCell *chatTableViewMailCell = [CellFactory cellChatTableViewMailCellFromTable:tableView forIndexPath:indexPath];
            [chatTableViewMailCell fillInformation:peppermintChatEntry];
            cell = chatTableViewMailCell;
        }
    } else {
        cell = [CellFactory cellChatTableViewCellFromTable:tableView forIndexPath:indexPath andDelegate:nil];
    }
    return cell;
}

-(CGFloat) calculatedHeight:(PeppermintChatEntry*)peppermintChatEntry indexPath:(NSIndexPath *)indexPath {
    NSString *key = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    NSNumber *cachedHeight = [calculatedHeightsDictionary objectForKey:key];
    if(!cachedHeight) {
        CGFloat calculatedHeight = 0;
        CGSize textSize = [peppermintChatEntry.mailContent sizeWithAttributes:@{NSFontAttributeName:[UIFont openSansFontOfSize:13]}];
        CGFloat estimatedHeigth = textSize.height * textSize.width / (SCREEN_WIDTH * 0.70);
        calculatedHeight = CELL_HEIGHT_CHAT_TABLEVIEWCELL + estimatedHeigth;
        calculatedHeight = MIN(calculatedHeight, CELL_HEIGHT_CHAT_TABLEVIEWMAILCELL_IDLE_MAX);
        cachedHeight = [NSNumber numberWithFloat:calculatedHeight];
        [calculatedHeightsDictionary setObject:cachedHeight forKey:key];
    }
    return cachedHeight.floatValue;
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {    
    CGFloat height = 0;
    if(self.chatEntryModel.chatEntriesArray.count > indexPath.row) {
        PeppermintChatEntry *peppermintChatEntry = (PeppermintChatEntry*)[self.chatEntryModel.chatEntriesArray objectAtIndex:indexPath.row];
        if(peppermintChatEntry.type == ChatEntryTypeAudio && self.chatEntryTypesToShow & ChatEntryTypeAudio) {
            if(peppermintChatEntry.transcription.length == 0) {
                height = CELL_HEIGHT_CHAT_TABLEVIEWCELL;
            } else {
                CGFloat transcriptionHeight = [ChatTableViewCell heightOfTranscriptionViewWithText:peppermintChatEntry.transcription
                                                                                    withFrameWidth:self.tableView.frame.size.width];
                height = CELL_HEIGHT_CHAT_TABLEVIEWCELL + transcriptionHeight;
            }
        } else if (peppermintChatEntry.type == ChatEntryTypeEmail && self.chatEntryTypesToShow & ChatEntryTypeEmail) {
            height = [self calculatedHeight:peppermintChatEntry indexPath:indexPath];
        }
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if([cell isKindOfClass:[ChatTableViewCell class]]) {
        ChatTableViewCell *chatTableViewCell = (ChatTableViewCell*)cell;
        [chatTableViewCell resetContent];
    }
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

    self.recordingView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:self.recordingView];
    [self.view bringSubviewToFront:self.recordingView];
    
    if([self.recordingView isKindOfClass:[FoggyRecordingView class]]) {
        FoggyRecordingView *foggyRecordingView = (FoggyRecordingView *)_recordingView;
        CGRect frame = foggyRecordingView.microphoneImageView.frame;
        foggyRecordingView.microphoneViewRightOffsetConstraint.constant =  -1 * (frame.size.width * 0.2);
        foggyRecordingView.microphoneViewCenterYConstraint.constant = -1 * (frame.size.height * 0.1);
    }
};

-(void) startAudioRecording {
    [self fireStopPlayingMessage];
    if(![RecordingModel checkRecordPermissions]) {
        [self initRecordingModel];
    } else {
        SendVoiceMessageModel *sendVoiceMessageModel = nil;
        if(self.peppermintContact.communicationChannel == CommunicationChannelEmail) {
            sendVoiceMessageModel = [SendVoiceMessageSparkPostModel new];
        } else if (self.peppermintContact.communicationChannel == CommunicationChannelSMS) {
            sendVoiceMessageModel = [SendVoiceMessageSMSModel new];
        }
        sendVoiceMessageModel.selectedPeppermintContact = self.peppermintContact;
        self.recordingView.sendVoiceMessageModel = sendVoiceMessageModel;
        
        CGRect rect = self.recordingButton.frame;
        [self.recordingView presentWithAnimationInRect:rect onPoint:CGPointMake(0, 0)];
    }
}

#pragma mark - RecordingGestureButtonDelegate

-(void) touchDownBeginOnIndexPath:(id) sender event:(UIEvent *)event {
    NSLog(@"touchDownBeginOnIndexPath");
}

-(void) touchHoldSuccessOnLocation:(CGPoint) touchBeginPoint {
    [self startAudioRecording];
}

-(void) touchSwipeActionOccuredOnLocation:(CGPoint) location {
    [self.recordingView finishRecordingWithGestureIsValid:NO needsPause:NO];
}

-(void) touchShortTapActionOccuredOnLocation:(CGPoint) location {
    weakself_create();
    [self.holdToRecordView showWithCompletionHandler:^{
        [weakSelf initRecordingModel];
    }];
}

-(void) initRecordingModel {
    RecordingModel *recordingModel = [RecordingModel new];
    recordingModel.delegate = self.recordingView;
}

-(void) touchCompletedAsExpectedWithSuccessOnLocation:(CGPoint) location {
    [self.recordingView finishRecordingWithGestureIsValid:YES needsPause:NO];
}

-(void) touchDownCancelledWithEvent:(UIEvent *)event location:(CGPoint)location {
    [self.recordingView finishedRecordingWithSystemCancel];
}

#pragma mark - RecordingViewDelegate

-(void) recordingViewDissappeared {
    NSLog(@"recordingViewDissappeared");
}

-(void) messageModel:(SendVoiceMessageModel*)messageModel isUpdatedWithStatus:(SendingStatus) sendingStatus cancelAble:(BOOL)isCacnelAble {
    BOOL shouldProcessDelegateMessage = [messageModel.selectedPeppermintContact isEqual:self.peppermintContact];
    if(shouldProcessDelegateMessage) {
#warning "Refactor code & merge below code with the one in 'ContactsViewController.m' "
        
        NSMutableAttributedString *infoAttrText = [NSMutableAttributedString new];
        UIColor *textColor = [UIColor textFieldTintGreen];
        self.microphoneView.hidden = self.bottomInformationLabel.hidden = YES;
        if(sendingStatus == SendingStatusInited) {
            [self resetBottomInformationLabel];
        } else if(sendingStatus == SendingStatusUploading) {
            [infoAttrText addText:LOC(@"Uploading", @"Info") ofSize:13 ofColor:textColor];
        } else if (sendingStatus == SendingStatusStarting) {
            [infoAttrText addText:LOC(@"Starting", @"Info") ofSize:13 ofColor:textColor];
        } else if (sendingStatus == SendingStatusSending) {
            [infoAttrText addText:LOC(@"Sending", @"Info") ofSize:13 ofColor:textColor];
        } else if ( sendingStatus == SendingStatusSendingWithNoCancelOption) {
            [infoAttrText addText:LOC(@"Sending", @"Info") ofSize:15 ofColor:textColor];
        }  else if (sendingStatus == SendingStatusSent) {
            [infoAttrText addImageNamed:@"icon_tick" ofSize:14];
            [infoAttrText addText:@"  " ofSize:14 ofColor:textColor];
            [infoAttrText addText:LOC(@"Sent", @"Info") ofSize:21 ofColor:textColor];
        }  else if (sendingStatus == SendingStatusCancelled) {
            [infoAttrText addText:LOC(@"Cancelled", @"Info") ofSize:13 ofColor:textColor];
        } else if (sendingStatus == SendingStatusCached) {
            [infoAttrText addImageNamed:@"icon_warning" ofSize:10];
            [infoAttrText addText:@" " ofSize:13 ofColor:textColor];
            [infoAttrText addText:LOC(@"Your message will be sent later", @"Cached Info") ofSize:10 ofColor:textColor];
        } else if (sendingStatus == SendingStatusError) {
            [infoAttrText addImageNamed:@"icon_warning" ofSize:13];
            [infoAttrText addText:@" " ofSize:13 ofColor:textColor];
            [infoAttrText addText:LOC(@"An error occured", @"Info") ofSize:13 ofColor:textColor];
        }
        
        if(isCacnelAble && infoAttrText.length > 0) {
            self.cancelSendingButton.hidden = NO;
            [infoAttrText addText:@"  " ofSize:13 ofColor:[UIColor peppermintCancelOrange]];
            [infoAttrText addText:LOC(@"Tap to cancel", @"Info") ofSize:13 ofColor:[UIColor peppermintCancelOrange]];
        } else {
            self.cancelSendingButton.hidden = YES;
        }
        self.bottomInformationFullLabel.attributedText = [infoAttrText centerText];
        
        weakself_create();
        switch (sendingStatus) {
            case  SendingStatusIniting:
            case  SendingStatusInited:
            case  SendingStatusStarting:
            case  SendingStatusUploading:
            case  SendingStatusSending:
                break;
            case  SendingStatusSendingWithNoCancelOption:
                [self refreshContent];
                break;
            case  SendingStatusError:
            case  SendingStatusCancelled:
            case  SendingStatusCached:
            case  SendingStatusSent:
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(BOTTOM_RESET_IME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf resetBottomInformationLabel];
                });
                break;
        }
    } else {
        NSLog(@"Didn't handle RecordingView delegate call for %@ cos screen is for %@",
              messageModel.selectedPeppermintContact.communicationChannelAddress, self.peppermintContact.communicationChannelAddress);
    }
}

-(void) newRecentContactisSaved {
    NSLog(@"newRecentContactisSaved");
}

-(void) chatHistoryCreatedWithSuccess {
    NSLog(@"chatHistoryCreatedWithSuccess");
    [self refreshContent];
}

#pragma mark - Cancel Message Sending

-(IBAction)cancelSendingButtonPressed:(id)sender {
    if(recordingPausedTimer) {
        [recordingPausedTimer invalidate];
        recordingPausedTimer = nil;
        [self.recordingView finishRecordingWithGestureIsValid:NO needsPause:NO];
    }
    [self.recordingView cancelMessageSending];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    isScrolling = YES;
    [self.holdToRecordView hide];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    isScrolling = NO;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    isScrolling = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    isScrolling = NO;
}

#pragma mark - ChatTableViewCellDelegate

-(void) startedPlayingMessage:(ChatTableViewCell*)chatTableViewCell {
    if(chatTableViewCell) {
        isPlaying = YES;
    }
}

-(void) stoppedPlayingMessage:(ChatTableViewCell*)chatTableViewCell {
    isPlaying = NO;
    //BOOL isPaused = chatTableViewCell.playingModel.audioPlayer.currentTime > 0.3;
    //if(scheduleRefresh && !isPaused) { //Decide to refresh on paused player or not?
    if(scheduleRefresh) {
        scheduleRefresh = NO;
        [self refreshContent];
    }
}

-(void) playMessageInCell:(ChatTableViewCell *)chatTableViewCell gotError:(NSError *)error {
    isPlaying = NO;
    [AppDelegate handleError:error];
}

#pragma mark - Refresh Content

SUBSCRIBE(ApplicationWillResignActive) {
    isPlaying = NO;
}

SUBSCRIBE(ApplicationDidBecomeActive) {
    scheduleRefresh = NO;
    [self checkToTakeOverSendingMessageEvents];
}

-(void) refreshContent {
    if(isPlaying) {
        scheduleRefresh = YES;
    } else {
        [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
        [self.chatEntryModel refreshPeppermintChatEntriesForContactEmail:self.peppermintContact.communicationChannelAddress];
    }
}

#pragma mark - AutoPlay

-(void) checkForAutoPlay {
    NSString *email = self.peppermintContact.communicationChannelAddress;
    BOOL isAutoPlayScheduled = [[AutoPlayModel sharedInstance] isScheduledForPeppermintContactWithEmail:email];
    if(isAutoPlayScheduled) {
        NSUInteger lastSection = 0;
        NSUInteger lastRowNumber = [self.tableView numberOfRowsInSection:lastSection] - 1;
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:lastRowNumber inSection:lastSection];
        ChatTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if(!cell.peppermintChatEntry.isSeen || cell.peppermintChatEntry.transcription.length > 0) {
            [cell playPauseButtonPressed:self];
        } else {
            NSLog(@"Last message is seen. Does not play automatically!");
        }
    }
}

SUBSCRIBE(RefreshIncomingMessagesCompletedWithSuccess) {
    NSArray *arrayToIterate =
    [ChatEntrySyncModel sharedInstance].isAllMessagesAreInSyncOfFirstCycle
    ? event.peppermintChatEntryNewMesssagesArray : event.peppermintChatEntryAllMesssagesArray;
    for(PeppermintChatEntry *peppermintChatEntry in arrayToIterate) {
        if([peppermintChatEntry.contactEmail caseInsensitiveCompare:self.peppermintContact.communicationChannelAddress] == NSOrderedSame) {
            [self refreshContent];
            break;
        }
    }
}

#pragma mark - lazy Loading

-(ChatEntryModel*) chatEntryModel {
    if(_chatEntryModel == nil) {
        _chatEntryModel = [ChatEntryModel new];
        _chatEntryModel.delegate = self;
        [_chatEntryModel refreshPeppermintChatEntriesForContactEmail:self.peppermintContact.communicationChannelAddress];
    }
    return _chatEntryModel;
}

-(RecordingView*) recordingView {
    if(_recordingView == nil) {
        [self initRecordingViewWithView:self.recordingButton];
    }
    return _recordingView;
}

#pragma mark - Proximity Sensor Monitor

-(void) startListeningProximitySensor {
    [[ProximitySensorModel sharedInstance] startMonitoring];
    [self.view becomeFirstResponder];
}

-(void) stopListeningProximitySensor {
    [[ProximitySensorModel sharedInstance] stopMonitoring];
    [self.view resignFirstResponder];
}

SUBSCRIBE(ProximitySensorValueIsUpdated) {
    BOOL isDeviceTakenToEar = event.isDeviceCloseToUser && event.isDeviceOrientationCorrectOnEar;
    BOOL isDeviceTakenOutOfEar = !event.isDeviceCloseToUser;
    BOOL existsMessagesToRead = [self doesExistUnheardMessage];
    BOOL isRecording = !self.recordingView.hidden;
    
    if(isPlaying) {
        NSLog(@"exist active playing.Don't take action...");
    } else if (isDeviceTakenToEar && existsMessagesToRead) {
        [self checkAndPlayFirstUnheardMessage];
    } else if (isDeviceTakenToEar && !existsMessagesToRead && !isRecording) {
        [self startAudioRecording];
    } else if (isDeviceTakenOutOfEar && isRecording) {
        [self pauseRecordingAndTriggerTimer];
    }
}

-(BOOL) doesExistUnheardMessage {
    BOOL result = NO;
    for(ChatTableViewCell *chatTableViewCell in self.tableView.visibleCells) {
        if(!chatTableViewCell.peppermintChatEntry.isSeen) {
            result = YES;
            break;
        }
    }
    return result;
}

-(void) checkAndPlayFirstUnheardMessage {
    for(ChatTableViewCell *chatTableViewCell in self.tableView.visibleCells) {
        if(!chatTableViewCell.peppermintChatEntry.isSeen) {
            [chatTableViewCell playPauseButtonPressed:self];
            break;
        }
    }
}

-(void) pauseRecordingAndTriggerTimer {
    [recordingPausedTimer invalidate];
    recordingPausedTimer = [NSTimer scheduledTimerWithTimeInterval:WAIT_FOR_SHAKE_DURATION
                                                      target:self
                                                    selector:@selector(completeRecordingPauseProcess)
                                                    userInfo:nil
                                                     repeats:NO];
    [self.recordingView finishRecordingWithGestureIsValid:YES needsPause:YES];
}

-(void) completeRecordingPauseProcess {
    weakself_create();
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.recordingView finishRecordingWithGestureIsValid:YES needsPause:NO];
    });
}

SUBSCRIBE(ShakeGestureOccured) {
    [self cancelSendingButtonPressed:self.cancelSendingButton];
}

@end
