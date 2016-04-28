//
//  EmailClientModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 22/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
@class BaseEmailSessionModel;

@interface EmailClientModel : BaseModel
@property (strong, nonatomic) NSMutableArray<BaseEmailSessionModel*> *emailSessionsArray;

-(void) startEmailClients;
@end
