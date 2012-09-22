//
//  ASZBusinessListingSingleton.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/8/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZBusinessListingSingleton.h"

@implementation ASZBusinessListingSingleton

static ASZBusinessListingSingleton *sharedDataListing = nil;

+ (ASZBusinessListingSingleton *) sharedDataListing
{
    
    @synchronized(self)
    {
        if (sharedDataListing == nil)
        {
            sharedDataListing = [[ASZBusinessListingSingleton alloc] init];
        }
    }
    return sharedDataListing;
}

- (ASBusinessListDataController*)getListDataController
{
    if (!self.dataController)
    {
        self.dataController = [[ASBusinessListDataController alloc]init];
    }
    return self.dataController;
    
}



@end
