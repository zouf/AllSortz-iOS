//
//  ASZBusinessListingSingleton.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/8/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASBusinessListDataController.h"

@interface ASZBusinessListingSingleton : NSObject
{
}

@property(nonatomic, strong) ASBusinessListDataController *dataController;
+ (ASZBusinessListingSingleton *) sharedDataListing;
- (ASBusinessListDataController*) getListDataController;
@end
