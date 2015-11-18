//
//  AWSModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 24/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import "AWSService.h"

@protocol AWSModelDelegate <BaseModelDelegate>
@required
-(void) recorderInitIsSuccessful;
-(void) fileUploadCompletedWithPublicUrl:(NSString*) url;
@end

@interface AWSModel : BaseModel
@property (weak, nonatomic) id<AWSModelDelegate> delegate;

+ (instancetype) sharedInstance;
-(void) initRecorder;
-(void) startToUploadData:(NSData*) data ofType:(NSString*) contentType;

@end
