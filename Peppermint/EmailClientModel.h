//
//  EmailClientModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 22/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import "ChatEntryModel.h"
@class BaseEmailSessionModel;

@protocol EmailClientModelDelegate <ChatEntryModelDelegate>
@end

@interface EmailClientModel : BaseModel <ChatEntryModelDelegate>
@property (weak, nonatomic) id<EmailClientModelDelegate> delegate;

@property (strong, nonatomic) NSMutableArray<BaseEmailSessionModel*> *emailSessionsArray;

-(void) startEmailClients;
@end
