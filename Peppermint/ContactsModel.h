//
//  ContactsModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import "Contact.h"

@interface ContactsModel : BaseModel

@property (strong, nonatomic) NSMutableArray *contactList;

@end
