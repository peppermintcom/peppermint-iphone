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

#define MIN_WIDTH_FOR_RIGHT_DATE_LABEL  20

@interface ContactTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel2ndLine;
@property (weak, nonatomic) IBOutlet UIImageView *rightIconImageView;

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
    self.showViaLabel = YES;
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

-(void) layoutSubviews {
    [super layoutSubviews];
    [self updateConstraintsManually];
}

-(void) updateConstraintsManually {
    NSString *text = [NSString stringWithFormat:@"%@__", self.rightDateLabel.text];
    CGFloat expectedWidth = [NSString widthOfText:text
                                         withSize:self.rightDateLabel.font.pointSize
                                        andHeight:self.rightDateLabel.frame.size.height];
    self.rightDateLabelWidthConstraint.constant = MAX(expectedWidth, MIN_WIDTH_FOR_RIGHT_DATE_LABEL);
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
    self.rightIconImageView.hidden = image == nil;
    self.rightIconImageView.image = image;
    if(image) {
        CGRect frame = self.informationLabel.frame;
        frame.size.width = self.rightIconImageView.frame.origin.x - frame.origin.x;
        self.informationLabel.frame = frame;
    }
    [self applyNonSelectedStyle];
}

#pragma mark - Set Avatar Image

-(void) setAvatarImage:(UIImage*) image {
    if(image) {
        CGRect frame = self.avatarImageView.frame;
        int width = frame.size.width;
        int height = frame.size.height;
        self.avatarImageView.image = [image resizedImageWithWidth:width height:height];
    } else {
        self.avatarImageView.image = [UIImage imageNamed:@"avatar_empty"];
    }
}

-(void) setAttributedText:(NSMutableAttributedString*) attributedText forLabel:(UILabel*)label {
    NSMutableParagraphStyle *paragraphStyleStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyleStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    [attributedText addAttribute:NSParagraphStyleAttributeName
                        value:paragraphStyleStyle
                        range:NSMakeRange(0, attributedText.length)];
    label.numberOfLines = 1;
    label.attributedText = attributedText;
}

-(void) applySelectedStyle {
    self.backgroundColor = [UIColor peppermintGreen];
    self.avatarImageView.layer.borderWidth = 2;
    
    NSMutableAttributedString *information = [NSMutableAttributedString new];
    [information addText:nameSurname ofSize:sizeLarge ofColor:[UIColor whiteColor] andFont:[UIFont openSansSemiBoldFontOfSize:sizeLarge]];
    [self setAttributedText:information forLabel:self.informationLabel];
    
    information = [NSMutableAttributedString new];
    if(self.showViaLabel) {
        [information addText:LOC(@"via", @"Localized value for the word via") ofSize:sizeSmall ofColor:[UIColor whiteColor] andFont:[UIFont openSansSemiBoldFontOfSize:sizeSmall]];
        [information addText:@" " ofSize:sizeSmall ofColor:[UIColor clearColor]];
    }
    [information addText:cellCommunicationChannelAddress ofSize:sizeSmall ofColor:[UIColor whiteColor] andFont:[UIFont openSansSemiBoldFontOfSize:sizeSmall]];
    [self setAttributedText:information forLabel:self.informationLabel2ndLine];
}

-(void) applyNonSelectedStyle {
    self.backgroundColor = [UIColor whiteColor];
    self.avatarImageView.layer.borderWidth = 0;
    
    NSMutableAttributedString *information = [NSMutableAttributedString new];
    [information addText:nameSurname ofSize:sizeLarge ofColor:[UIColor blackColor] andFont:[UIFont openSansSemiBoldFontOfSize:sizeLarge]];
    [self setAttributedText:information forLabel:self.informationLabel];
    
    information = [NSMutableAttributedString new];
    if(self.showViaLabel) {
        [information addText:LOC(@"via", @"Localized value for the word via") ofSize:sizeSmall ofColor:[UIColor textFieldTintGreen] andFont:[UIFont openSansSemiBoldFontOfSize:sizeSmall]];
        [information addText:@" " ofSize:sizeSmall ofColor:[UIColor clearColor]];
    }
    [information addText:cellCommunicationChannelAddress ofSize:sizeSmall ofColor:[UIColor viaInformationLabelTextGreen] andFont:[UIFont openSansSemiBoldFontOfSize:sizeSmall]];
    [self setAttributedText:information forLabel:self.informationLabel2ndLine];
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

-(BOOL) isTableViewBouncing {
    //Recognising bouncing up, bouncing down can be added..
    return self.tableView.contentOffset.y < 0;
}

-(void) touchHoldSuccessOnLocation:(CGPoint) touchBeginPoint {
    if(![self isTableViewBouncing]) {
        [self.delegate didBeginItemSelectionOnIndexpath:self.indexPath location:touchBeginPoint];
    } else {
        NSLog(@"TableView is bouncing...");
    }
}

-(void) touchSwipeActionOccuredOnLocation:(CGPoint) location {
    [self applyNonSelectedStyle];
    [self.delegate didFinishItemSelectionWithSwipeActionOccuredOnLocation:self.indexPath location:location];
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