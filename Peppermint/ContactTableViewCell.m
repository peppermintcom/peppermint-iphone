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

#define EVENT                   @"Event"
#define HOLD_LIMIT              0.050
#define SWIPE_SPEED_LIMIT       20

#define SIZE_LARGE          17
#define SIZE_SMALL          13

#define INFORMATION_LABEL_RIGHT_CONSTANT        40
#define INFORMATION_LABEL_RIGHT_CONSTANT_MIN    8

@interface ContactTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rightIconImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *informationLabelRightConstraint;

@end

@implementation ContactTableViewCell {
    CGPoint touchBeginPoint;
    NSTimer *timer;
    UIView *rootView;
    BOOL isCellAvailableToHaveUserInteraction;

    NSString *nameSurname;
    NSString *communicationChannelAddress;
    
    NSUInteger sizeLarge;
    NSUInteger sizeSmall;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatarImageView.layer.cornerRadius = 5;
    self.avatarImageView.layer.borderColor  = [UIColor whiteColor].CGColor;
    self.cellSeperatorView.backgroundColor = [UIColor cellSeperatorGray];
    timer = nil;
    rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    isCellAvailableToHaveUserInteraction = YES;
    sizeLarge = SIZE_LARGE;
    sizeSmall = SIZE_SMALL;
}

#pragma mark - Arrange Font size and Place Text

-(CGFloat) widthOfText:(NSString*)text withSize:(NSUInteger)size {
    NSMutableAttributedString *attrText = [NSMutableAttributedString new];
    [attrText addText:text ofSize:size ofColor:[UIColor clearColor] andFont:[UIFont openSansSemiBoldFontOfSize:size]];
    CGRect paragraphRect = [attrText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.informationLabel.frame.size.height / 2)
                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                 context:nil];
    return paragraphRect.size.width;
}

-(void) calculateCorrectSizeForFonts {
    CGFloat width = self.informationLabel.frame.size.width;
    while ([self widthOfText:nameSurname withSize:sizeLarge] > width) {
        nameSurname = [nameSurname limitTo:nameSurname.length - 3];
    }
    
    width = self.informationLabel.frame.size.width * 3/4;
    while ([self widthOfText:communicationChannelAddress withSize:sizeSmall] > width) {
        communicationChannelAddress = [communicationChannelAddress limitTo:communicationChannelAddress.length - 3];
    }
}

-(void) setInformationWithNameSurname:(NSString*)contactNameSurname communicationChannelAddress:(NSString*)contactCommunicationChannelAddress {
    [self setInformationWithNameSurname:contactNameSurname communicationChannelAddress:contactCommunicationChannelAddress andIconImage:nil];
}

-(void) setInformationWithNameSurname:(NSString*)contactNameSurname communicationChannelAddress:(NSString*)contactCommunicationChannelAddress andIconImage:(UIImage*) image {
    nameSurname = contactNameSurname;
    communicationChannelAddress = contactCommunicationChannelAddress;    
    NSAssert(nameSurname.length > 0 && communicationChannelAddress.length > 0, @"NameSurname&communicationchannel address must be supplied");
    
    self.rightIconImageView.hidden = image == nil;
    self.rightIconImageView.image = image;
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
    [information addText:communicationChannelAddress ofSize:sizeSmall ofColor:[UIColor whiteColor] andFont:[UIFont openSansSemiBoldFontOfSize:sizeSmall]];
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
    [information addText:communicationChannelAddress ofSize:sizeSmall ofColor:[UIColor viaInformationLabelTextGreen] andFont:[UIFont openSansSemiBoldFontOfSize:sizeSmall]];
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

-(IBAction) touchDownOnIndexPath:(id) sender event:(UIEvent *)event {
    if([self isAllowedToHandleTouch] && isCellAvailableToHaveUserInteraction) {
        isCellAvailableToHaveUserInteraction = NO;
        [self applySelectedStyle];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:event forKey:EVENT];
        touchBeginPoint = CGPointMake(0, 0);
        timer = [NSTimer scheduledTimerWithTimeInterval:HOLD_LIMIT target:self selector:@selector(touchingHold) userInfo:userInfo repeats:NO];
    }
}

-(void) touchingHold {
    if(!isCellAvailableToHaveUserInteraction) {
        UIEvent *event = [timer.userInfo valueForKey:EVENT];
        [timer invalidate];
        UITouch *touch = [[event allTouches] anyObject];
        touchBeginPoint = [touch locationInView:rootView];
        [self.delegate didBeginItemSelectionOnIndexpath:self.indexPath location:touchBeginPoint];
    }
}

-(IBAction) touchDragging:(id)sender event:(UIEvent *)event {
    if(timer) {
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint location = [touch locationInView:rootView];
        CGRect bounds = UIScreen.mainScreen.bounds;
        
        BOOL speedIsInLimit = YES;
        if(touchBeginPoint.x != 0 || touchBeginPoint.y != 0) {
            CGFloat xDist = (location.x - touchBeginPoint.x);
            CGFloat yDist = (location.y - touchBeginPoint.y);
            CGFloat speed = sqrt((xDist * xDist) + (yDist * yDist));
            touchBeginPoint = location;
            speedIsInLimit = speed <= SWIPE_SPEED_LIMIT;
        }
        
        BOOL isOutOfBounds = bounds.origin.x >= location.x || bounds.origin.y >= location.y
        || bounds.size.width <= location.x || bounds.size.height <= location.y;
        
        if(!isCellAvailableToHaveUserInteraction && (!speedIsInLimit || isOutOfBounds)) {
            if(timer.isValid)
                [timer invalidate];
            timer = nil;
            [self applyNonSelectedStyle];
            isCellAvailableToHaveUserInteraction = YES;
            [self.delegate didCancelItemSelectionOnIndexpath:self.indexPath location:touchBeginPoint];
        }
    }
}

-(IBAction) touchDownFinishedOnIndexPath:(id) sender event:(UIEvent *)event {
    if(!isCellAvailableToHaveUserInteraction) {
        isCellAvailableToHaveUserInteraction = YES;
        if(timer != nil) {
            [self applyNonSelectedStyle];
            if(timer.isValid)  {
                [timer invalidate];
                timer = nil;
                UITouch *touch = [[event allTouches] anyObject];
                CGPoint endPoint = [touch locationInView:rootView];
                [self.delegate didShortTouchOnIndexPath:self.indexPath location:endPoint];
            } else {
                timer = nil;
                [self.delegate didFinishItemSelectionOnIndexPath:self.indexPath location:touchBeginPoint];
            }
        }
    }
}

-(IBAction) touchDownCancelledOnIndexPath:(id) sender event:(UIEvent *)event {
    NSLog(@"touchDownCancelledOnIndexPath:(id) sender event:(UIEvent *)event");
    if(timer.isValid)
        [timer invalidate];
    timer = nil;
    [self applyNonSelectedStyle];
    isCellAvailableToHaveUserInteraction = YES;
    [self.delegate didCancelItemSelectionOnIndexpath:self.indexPath location:touchBeginPoint];
}

@end