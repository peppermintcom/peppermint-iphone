//
//  CustomContactModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 04/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
@class PeppermintContact;

@protocol CustomContactModelDelegate <BaseModelDelegate>
-(void) customPeppermintContactSavedSucessfully:(PeppermintContact*) peppermintContact;
@end

@interface CustomContactModel : BaseModel
@property (weak, nonatomic) id<CustomContactModelDelegate> delegate;
-(void) save:(PeppermintContact*) peppermintContact;
+(NSArray*) peppermintContactsArrayWithFilterText:(NSString*) filterText;

@end
