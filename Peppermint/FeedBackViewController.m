//
//  FeedBackViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 05/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "FeedBackViewController.h"
#import "PeppermintContact.h"
#import "SendVoiceMessageMandrillModel.h"
#import "ProximitySensorModel.h"

#define TITLE_TEXT_SIZE                     20
#define SUPPORT_EMAIL_TEXT_SIZE             15

@interface FeedBackViewController ()

@end

@implementation FeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Title
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont openSansSemiBoldFontOfSize:TITLE_TEXT_SIZE];
    self.titleLabel.text = LOC(@"Feedback",@"Feedback");
    
    //SupportEmail
    self.supportEmailLabel.textColor = [UIColor privacyPolicyGreen];
    self.supportEmailLabel.font = [UIFont openSansSemiBoldFontOfSize:SUPPORT_EMAIL_TEXT_SIZE];
    self.supportEmailLabel.text = LOC(@"Or email us for support",@"Or email us for support");
    [self.supportEmailLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(supportEmailLabelPressed)]];
    
    self.tableView.rowHeight = CELL_HEIGHT_CONTACT_TABLEVIEWCELL;
    
    self.feedBackModel = [FeedBackModel new];
    self.feedBackModel.delegate = self;
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void) supportEmailLabelPressed {
    [self.feedBackModel sendFeedBackMail];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.feedBackModel.supportContactsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = [CellFactory cellContactTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
    cell.showViaLabel = NO;
    PeppermintContact *peppermintContact = [self.feedBackModel.supportContactsArray objectAtIndex:indexPath.row];
    [cell setInformationWithNameSurname:peppermintContact.nameSurname communicationChannelAddress:peppermintContact.explanation];
    return cell;
}

#pragma mark - Create Instance

+(instancetype) createInstance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_MAIN bundle:[NSBundle mainBundle]];
    FeedBackViewController *feedBackViewController = [storyboard instantiateViewControllerWithIdentifier:VIEWCONTROLLER_FEEDBACK];
    return feedBackViewController;
}

#pragma mark - CloseButton

-(IBAction)backButtonPressed:(id)sender {
    if(!self.navigationController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - ContactTableViewCellDelegate

-(void) didShortTouchOnIndexPath:(NSIndexPath*) indexPath location:(CGPoint) location {
    NSLog(@"didShortTouchOnIndexPath:");
}

-(void) didBeginItemSelectionOnIndexpath:(NSIndexPath*) indexPath location:(CGPoint) location {
    PeppermintContact *peppermintContact = [self.feedBackModel.supportContactsArray objectAtIndex:indexPath.row];
    if(peppermintContact.communicationChannel == CommunicationChannelEmail) {
        CGRect cellRect = [self.tableView rectForRowAtIndexPath:indexPath];
        cellRect = [self.tableView convertRect:cellRect toView:self.view];
        SendVoiceMessageEmailModel *sendVoiceMessageModel = [SendVoiceMessageMandrillModel new];
        sendVoiceMessageModel.subject = LOC(@"Feedback Subject", @"Feedback Subject");
        sendVoiceMessageModel.selectedPeppermintContact = peppermintContact;
        self.recordingView.sendVoiceMessageModel = sendVoiceMessageModel;
        [self.recordingView presentWithAnimationInRect:cellRect onPoint:location];
    } else {
        NSLog(@"Not supported communication channel:%ld", (unsigned long)peppermintContact.communicationChannel);
    }
}

-(void) didCancelItemSelectionOnIndexpath:(NSIndexPath*) indexPath location:(CGPoint) location {
    [self.recordingView finishRecordingWithGestureIsValid:NO needsPause:NO];
}

-(void) didFinishItemSelectionOnIndexPath:(NSIndexPath*) indexPath location:(CGPoint) location {
    [self.recordingView finishRecordingWithGestureIsValid:YES needsPause:NO];
}

#pragma mark - RecordingView

-(RecordingView*) recordingView {
    if(self._recordingView == nil) {
        self._recordingView = [FoggyRecordingView createInstanceWithDelegate:self];
        self._recordingView.frame = self.view.frame;
        [self.view addSubview:self._recordingView];
        [self.view bringSubviewToFront:self._recordingView];
    }
    return self._recordingView;
}

#pragma mark - RecordingViewDelegate

-(void) newRecentContactisSaved {
    NSLog(@"newRecentContact Request is processed. It is saved if it is not RestrictedForRecentContact");
}

-(void) chatHistoryCreatedWithSuccess {
    NSLog(@"chatHistoryCreatedWithSuccess");
}

-(void) recordingViewDissappeared {
    NSLog(@"recordingViewDissappeared");
}

-(void) messageModel:(SendVoiceMessageModel*) messageModel isUpdatedWithStatus:(SendingStatus) sendingStatus cancelAble:(BOOL)isCacnelAble {
    if(messageModel == [self recordingView].sendVoiceMessageModel) {
        NSLog(@"message:isUpdatedWithStatus:%ld", (unsigned long)sendingStatus);
        if(sendingStatus == SendingStatusSent) {
            [self feedBackSentWithSuccess];
        }
    }
}

#pragma mark - FeedBackModelDelegate

-(void) operationFailure:(NSError*) error {
    [super operationFailure:error];
}

-(void) feedBackSentWithSuccess {
    NSString *title = LOC(@"Information", @"Information");
    NSString *message = LOC(@"Feedback sent with success", @"Feedback sent with success");
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
}


/*

Uncomment For "Raise to Record Gesture"
 
#pragma mark - Recording Gesture

SUBSCRIBE(ProximitySensorValueIsUpdated) {
    [super onProximitySensorValueIsUpdated:event];
}

SUBSCRIBE(ShakeGestureOccured) {
    [super onShakeGestureOccured:event];
}

-(void) recordingIsTriggeredWithGesture {
    [super recordingIsTriggeredWithGesture];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self didBeginItemSelectionOnIndexpath:indexPath location:CGPointZero];
}

-(void) cancelSending {
    [super cancelSending];
}
*/

@end
