//
//  ContactTableViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "ContactTableViewCell.h"
#import "Tolo.h"
#import "Events.h"

#define SIZE_LARGE              17
#define SIZE_SMALL              13

#define INFORMATION_LABEL_RIGHT_CONSTANT        40
#define INFORMATION_LABEL_RIGHT_CONSTANT_MIN    8

@interface ContactTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *informationLabelRightConstraint;

@end

@implementation ContactTableViewCell {
    NSString *nameSurname;
    NSString *cellCommunicationChannelAddress;
    NSUInteger sizeLarge;
    NSUInteger sizeSmall;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.recordingGestureButton.delegate = self;
    self.avatarImageView.layer.cornerRadius = 5;
    self.avatarImageView.layer.borderColor  = [UIColor whiteColor].CGColor;
    self.cellSeperatorView.backgroundColor = [UIColor cellSeperatorGray];
    
    nameSurname = @"";
    cellCommunicationChannelAddress = @"";
    sizeLarge = SIZE_LARGE;
    sizeSmall = SIZE_SMALL;
    
    [self initRecentContactViews];
}

-(void) initRecentContactViews {
    int fontSize = 12;
#warning "Check font size&update to SIZE_SMALL if possible?"
    self.rightDateLabel.font = [UIFont openSansSemiBoldFontOfSize:fontSize];
    self.rightDateLabel.textColor = [UIColor textFieldTintGreen];
    
    self.rightMessageCounterLabel.font = [UIFont openSansSemiBoldFontOfSize:fontSize];
    self.rightMessageCounterLabel.backgroundColor = [UIColor viaInformationLabelTextGreen];
    self.rightMessageCounterLabel.textColor = [UIColor whiteColor];
    self.rightMessageCounterLabel.layer.cornerRadius = 4;
}

#pragma mark - Arrange Font size and Place Text

-(void) calculateCorrectSizeForFonts {
    CGFloat width = self.informationLabel.frame.size.width;
    CGFloat height = self.informationLabel.frame.size.height / 2;
    while ([NSString widthOfText:nameSurname withSize:sizeLarge andHeight:height] > width) {
        nameSurname = [nameSurname limitTo:nameSurname.length - 3];
    }
    
    width = self.informationLabel.frame.size.width * 0.90;
    while ([NSString widthOfText:cellCommunicationChannelAddress withSize:sizeSmall andHeight:height] > width) {
        cellCommunicationChannelAddress = [cellCommunicationChannelAddress limitTo:cellCommunicationChannelAddress.length - 3];
    }
}

-(void) setInformationWithNameSurname:(NSString*)contactNameSurname communicationChannelAddress:(NSString*)contactCommunicationChannelAddress
{
    [self setInformationWithNameSurname:contactNameSurname communicationChannelAddress:contactCommunicationChannelAddress andIconImage:nil];
}

-(void) setInformationWithNameSurname:(NSString*)contactNameSurname communicationChannelAddress:(NSString*)contactCommunicationChannelAddress andIconImage:(UIImage*) image {
    nameSurname = contactNameSurname;
    cellCommunicationChannelAddress = contactCommunicationChannelAddress;    
    NSAssert(nameSurname.length > 0 && cellCommunicationChannelAddress.length > 0, @"NameSurname&communicationchannel address lengths must be longer than 0");
    
    self.rightDateLabel.text = @"";
    self.rightMessageCounterLabel.text = @"";
    self.rightMessageCounterLabel.hidden = YES;
    self.informationLabelRightConstraint.constant = image == nil ? INFORMATION_LABEL_RIGHT_CONSTANT_MIN : INFORMATION_LABEL_RIGHT_CONSTANT;
    
    [self calculateCorrectSizeForFonts];
    [self applyNonSelectedStyle];
}

#pragma mark - Set Avatar Image

-(void) setAvatarImage:(UIImage*) image {
    CGRect frame = self.avatarImageView.frame;
    int width = frame.size.width;
    int height = frame.size.height;
    self.avatarImageView.image = [image resizedImageWithWidth:width height:height];
}

-(void) applySelectedStyle {
    self.backgroundColor = [UIColor peppermintGreen];
    self.avatarImageView.layer.borderWidth = 2;
    
    NSMutableAttributedString *information = [NSMutableAttributedString new];
    [information addText:nameSurname ofSize:sizeLarge ofColor:[UIColor whiteColor] andFont:[UIFont openSansSemiBoldFontOfSize:sizeLarge]];
    [information addText:@"\n" ofSize:sizeLarge ofColor:[UIColor clearColor]];
    [information addText:LOC(@"via", @"Localized value for the word via") ofSize:sizeSmall ofColor:[UIColor whiteColor] andFont:[UIFont openSansSemiBoldFontOfSize:sizeSmall]];
    [information addText:@" " ofSize:sizeSmall ofColor:[UIColor clearColor]];
    [information addText:cellCommunicationChannelAddress ofSize:sizeSmall ofColor:[UIColor whiteColor] andFont:[UIFont openSansSemiBoldFontOfSize:sizeSmall]];
    [self.informationLabel setAttributedText:information];
}

-(void) applyNonSelectedStyle {
    self.backgroundColor = [UIColor whiteColor];
    self.avatarImageView.layer.borderWidth = 0;
    
    NSMutableAttributedString *information = [NSMutableAttributedString new];
    [information addText:nameSurname ofSize:sizeLarge ofColor:[UIColor blackColor] andFont:[UIFont openSansSemiBoldFontOfSize:sizeLarge]];
    [information addText:@"\n" ofSize:sizeSmall ofColor:[UIColor clearColor]];
    [information addText:LOC(@"via", @"Localized value for the word via") ofSize:sizeSmall ofColor:[UIColor textFieldTintGreen] andFont:[UIFont openSansSemiBoldFontOfSize:sizeSmall]];
    [information addText:@" " ofSize:sizeSmall ofColor:[UIColor clearColor]];
    [information addText:cellCommunicationChannelAddress ofSize:sizeSmall ofColor:[UIColor viaInformationLabelTextGreen] andFont:[UIFont openSansSemiBoldFontOfSize:sizeSmall]];
    [self.informationLabel setAttributedText:information];
    
}

#pragma mark - Action Buttons

-(BOOL) isAllCellsNonSelectedInTable {
    BOOL isContactSelectionAvailable = YES;
    for(UITableViewCell *cell in self.tableView.visibleCells) {
        if([cell isKindOfClass:[ContactTableViewCell class]] && cell.backgroundColor != self.backgroundColor) {
            isContactSelectionAvailable = NO;
            break;
        }
    }
    return isContactSelectionAvailable;
}

-(BOOL) isAllowedToHandleTouch {
    CGPoint scrollPoint = self.tableView.contentOffset;
    CGFloat tableMaxScrollValue = self.tableView.contentSize.height - self.tableView.bounds.size.height;
    BOOL isTableInScrollingState = (scrollPoint.y < 0) || (scrollPoint.y > 0 && scrollPoint.y > tableMaxScrollValue);
    BOOL result = !isTableInScrollingState && [self isAllCellsNonSelectedInTable];
    return result;
}

#pragma mark - RecordingGestureButtonDelegate

-(void) touchDownBeginOnIndexPath:(id) sender event:(UIEvent *)event {
    if([self isAllowedToHandleTouch]) {
        [self applySelectedStyle];
    }
}

-(void) touchHoldSuccessOnLocation:(CGPoint) touchBeginPoint {
    [self.delegate didBeginItemSelectionOnIndexpath:self.indexPath location:touchBeginPoint];
}

-(void) touchSwipeActionOccuredOnLocation:(CGPoint) location {
    [self applyNonSelectedStyle];
    [self.delegate didCancelItemSelectionOnIndexpath:self.indexPath location:location];
}

-(void) touchShortTapActionOccuredOnLocation:(CGPoint) location {
    [self applyNonSelectedStyle];
    [self.delegate didShortTouchOnIndexPath:self.indexPath location:location];
}

-(void) touchCompletedAsExpectedWithSuccessOnLocation:(CGPoint) location {
    [self applyNonSelectedStyle];
    [self.delegate didFinishItemSelectionOnIndexPath:self.indexPath location:location];
}

-(void) touchDownCancelledWithEvent:(UIEvent *)event location:(CGPoint) location {
    [self applyNonSelectedStyle];
    [self.delegate didCancelItemSelectionOnIndexpath:self.indexPath location:location];
}

@end