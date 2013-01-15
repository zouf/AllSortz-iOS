//
//  ASZBusinessReviewsDataController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 1/9/13.
//  Copyright (c) 2013 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASBusiness.h"

@interface ASZBusinessReviewsDataController : NSObject <UITableViewDataSource>
@property(nonatomic,retain) ASBusiness* business;

@end
