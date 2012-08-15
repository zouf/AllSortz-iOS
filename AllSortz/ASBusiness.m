//
//  ASBusiness.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 8/9/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASBusiness.h"


@implementation ASBusiness

- (id)initWithID:(NSUInteger)anID
{
    if (!(self = [super init]))
        return nil;
    // TODO: Maintain unique instances of businesses
    _ID = anID;
    return self;
}

- (id)init
{
    // Instances *must* be created with an ID
    return nil;
}

#pragma mark - Custom setters

- (void)setHours:(NSArray *)hours
{
    // TODO: Switch to more structured representation
    // TODO: Check representation
    _hours = hours;
}

- (void)setAddress:(NSString *)address
{
    // TODO: Switch to more structured representation
    // TODO: Check representation
    _address = address;
}

- (void)setPhone:(NSString *)phone
{
    // TODO: Switch to more structured representation
    // TODO: Check representation
    _phone = phone;
}
@end
