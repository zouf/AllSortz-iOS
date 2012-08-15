//
//  ASBusiness.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 8/9/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASBusiness.h"
#import "ASException.h"

#ifndef CHECK_FOR_MULTI_ASSIGN
#define CHECK_FOR_MULTI_ASSIGN(ivar) \
    do { \
        if (ivar) { \
            NSString *AS_reason = @"Cannot assign to " #ivar " more than once"; \
            @throw [NSException exceptionWithName:ASMultipleAssignmentException \
                                           reason:AS_reason \
                                         userInfo:nil]; \
        } \
    } while(0)
#endif


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
    CHECK_FOR_MULTI_ASSIGN(_hours);
    // TODO: Switch to more structured representation
    // TODO: Check representation
    _hours = hours;
}

- (void)setImage:(UIImage *)image
{
    CHECK_FOR_MULTI_ASSIGN(_image);
    _image = image;
}

- (void)setImageID:(NSUInteger)imageID
{
    CHECK_FOR_MULTI_ASSIGN(_imageID);
    _imageID = imageID;
}

- (void)setAddress:(NSString *)address
{
    CHECK_FOR_MULTI_ASSIGN(_address);
    // TODO: Switch to more structured representation
    // TODO: Check representation
    _address = address;
}

- (void)setName:(NSString *)name
{
    CHECK_FOR_MULTI_ASSIGN(_name);
    _name = name;
}

- (void)setPhone:(NSString *)phone
{
    CHECK_FOR_MULTI_ASSIGN(_phone);
    // TODO: Switch to more structured representation
    // TODO: Check representation
    _phone = phone;
}

- (void)setScore:(NSNumber *)score
{
    CHECK_FOR_MULTI_ASSIGN(_score);
    _score = score;
}

- (void)setWebsite:(NSURL *)website
{
    CHECK_FOR_MULTI_ASSIGN(_website);
    _website = website;
}

@end
