//
//  CountryFormatModel.h
//  Peppermint
//
//  Created by Yan Saraev on 11/26/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"

@interface CountryFormatModel : BaseModel

- (NSArray *)countriesList;
- (NSString *)countryCodeFromDisplayName:(NSString *)displayName;

- (NSString *)phoneCodeFromCountryCodeISO:(NSString *)code;


@end
