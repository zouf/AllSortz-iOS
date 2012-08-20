//
//  ASListing.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/10/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASListing.h"


@implementation ASListing

- (id)initWithID:(NSUInteger)anID
{
    if (!(self = [super init]))
        return nil;
    _ID = anID;
    return self;
}

- (id)init
{
    // Must initialize with an ID
    return nil;
}

@end
