//
//  ChatEntriesViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 19/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatEntriesViewController.h"
#import "SendVoiceMessageMandrillModel.h"

@interface ChatEntriesViewController () <RecordingGestureButtonDelegate>

@end

@implementation ChatEntriesViewController

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSParameterAssert(self.chatEntriesModel);
    self.chatEntriesModel.delegate = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.chatEntriesModel refreshChatEntries];
    
    if(self.chatEntriesModel.chat.avatarImageData) {
        self.avatarImageView.image = [UIImage imageWithData:self.chatEntriesModel.chat.avatarImageData];
    }
    NSMutableAttributedString *attrText = [NSMutableAttributedString new];
    [attrText addText:self.chatEntriesModel.chat.nameSurname ofSize:17 ofColor:[UIColor whiteColor] andFont:[UIFont openSansSemiBoldFontOfSize:17]];
    [attrText addText:@"\n" ofSize:12 ofColor:[UIColor clearColor]];
    [attrText addText:self.chatEntriesModel.chat.communicationChannelAddress ofSize:13 ofColor:[UIColor recordingNavigationsubTitleGreen]];
    [attrText centerText];
    self.titleLabel.attributedText = attrText;
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initRecordingViewWithView:self.recordingButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.chatEntriesModel = nil;
    self.recordingView = nil;
}

#pragma mark - ChatEntriesModelDelegate

-(void) chatEntriesArrayIsUpdated {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self navigateToLastRow];
}

-(void) navigateToLastRow {
    [self.tableView reloadData];
#warning "navigate to the last row!"
    /*
    NSUInteger lastSection = 0;
    NSUInteger lastRowNumber = [self.tableView numberOfRowsInSection:lastSection] - 1;
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:lastRowNumber inSection:lastSection];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
     */
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = [self.chatEntriesModel.chatEntriesArray count];
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ChatTableViewCell *cell = [CellFactory cellChatTableViewCellFromTable:tableView forIndexPath:indexPath];    
    ChatEntry *chatEntry = (ChatEntry*)[self.chatEntriesModel.chatEntriesArray objectAtIndex:indexPath.row];
    [cell fillInformation:chatEntry];
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
    rect.size.width *= 1.20;
    self.recordingView.frame = rect;
    [self.view addSubview:self.recordingView];
    [self.view bringSubviewToFront:self.recordingView];
    
    FoggyRecordingView *foggyRecordingView = (FoggyRecordingView*)self.recordingView;
    if(foggyRecordingView) {
        foggyRecordingView.swipeInAnyDirectionView.hidden = YES;
    }
};


#pragma mark - RecordingGestureButtonDelegate

-(void) touchDownBeginOnIndexPath:(id) sender event:(UIEvent *)event {
    NSLog(@"touchDownBeginOnIndexPath");
}

-(void) touchHoldSuccessOnLocation:(CGPoint) touchBeginPoint {
    SendVoiceMessageModel *sendVoiceMessageModel = [SendVoiceMessageMandrillModel new];
    
    PeppermintContact *peppermintContact = [PeppermintContact new];
    peppermintContact.nameSurname = @"T Okan Kurtulus";
    peppermintContact.communicationChannel = CommunicationChannelEmail;
    peppermintContact.communicationChannelAddress = @"okankurtulus@gmail.com";
    sendVoiceMessageModel.selectedPeppermintContact = peppermintContact;
    self.recordingView.sendVoiceMessageModel = sendVoiceMessageModel;
    
    CGRect rect = self.recordingButton.frame;
    [self.recordingView presentWithAnimationInRect:rect onPoint:CGPointMake(0, 0)];
}

-(void) touchSwipeActionOccuredOnLocation:(CGPoint) location {
    [self.recordingView finishRecordingWithGestureIsValid:NO];
}

-(void) touchShortTapActionOccuredOnLocation:(CGPoint) location {
    NSLog(@"touchShortTapActionOccuredOnLocation");
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
    [self.chatEntriesModel refreshChatEntries];
}

-(void) message:(NSString*) message isUpdatedWithStatus:(SendingStatus) sendingStatus cancelAble:(BOOL)isCacnelAble {
    NSLog(@"message:isUpdatedWithStatus:cancelable:");
}

-(void) newRecentContactisSaved {
    NSLog(@"newRecentContactisSaved");
}

@end
