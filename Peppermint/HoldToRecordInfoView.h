//
//  HoldToRecordInfoView.h
//  Peppermint
//
//  Created by Okan Kurtulus on 30/05/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseCustomView.h"

@interface HoldToRecordInfoView : BaseCustomView
@property (weak, nonatomic) IBOutlet UILabel *holdToRecordInfoViewLabel;

-(void) showWithCompletionHandler:(void (^)(void))completionHandler;
-(void) hide;

@end
