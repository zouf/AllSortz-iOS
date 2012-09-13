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

#ifndef SIMPLE_SETTER
#define SIMPLE_SETTER(lower_name, caps_name, type) \
    - (void)set ## caps_name:(type)lower_name \
    { \
        CHECK_FOR_MULTI_ASSIGN(_ ## lower_name); \
        _ ## lower_name = lower_name; \
    }
#endif


@implementation ASBusiness

- (id)initWithID:(NSUInteger)anID
{
    if (!(self = [super init]) || anID == 0)
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

SIMPLE_SETTER(address, Address, NSString *)
SIMPLE_SETTER(city, City, NSString *)
SIMPLE_SETTER(state, State, NSString *)
SIMPLE_SETTER(zipcode, Zipcode, NSString *)

SIMPLE_SETTER(hours, Hours, NSArray *)
SIMPLE_SETTER(name, Name, NSString *)
SIMPLE_SETTER(phone, Phone, NSString *)
SIMPLE_SETTER(recommendation, Recommendation, CGFloat)
SIMPLE_SETTER(distance, Distance, NSNumber *)



SIMPLE_SETTER(website, Website, NSURL *)

SIMPLE_SETTER(healthGrade, HealthGrade, NSString *)

SIMPLE_SETTER(image, Image, UIImage *)
SIMPLE_SETTER(imageID, ImageID, NSUInteger)

SIMPLE_SETTER(score, Score, NSNumber *)


SIMPLE_SETTER(types, Types, NSArray *)

SIMPLE_SETTER(topics, Topics, NSArray *)

@end
