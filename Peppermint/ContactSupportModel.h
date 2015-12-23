//
//  ContactSupportModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 23/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"

@protocol ContactSupportModelDelegate <BaseModelDelegate>
-(void) contactSupportMailSentWithSuccess;
@end

@interface ContactSupportModel : BaseModel
@property (weak, nonatomic) id<ContactSupportModelDelegate> delegate;
-(void) sendContactSupportMail;

@end