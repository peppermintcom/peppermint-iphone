//
//  MessageBarManagerModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 12/05/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"

@interface MessageBarManagerModel : BaseModel
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* nameSurname;
@property (strong, nonatomic) NSString* messageBody;
@property (strong, nonatomic) NSString* messageTitle;
@property (strong, nonatomic) UIImage* avatarImage;

-(void) triggerMessageWithPressedCallBack:(nullable void (^)())callback;

@end
