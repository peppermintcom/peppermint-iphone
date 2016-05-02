//
//  PeppermintGIdSignIn.h
//  Peppermint
//
//  Created by Okan Kurtulus on 25/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import <Google/SignIn.h>

@interface PeppermintGIdSignIn : BaseModel

+(GIDSignIn*) GIdSignInInstance;

@end
