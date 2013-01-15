//
//  ASZMenuDataController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 1/8/13.
//  Copyright (c) 2013 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASBusiness.h"
#import "ASZMenuList.h"

#define NAME_TAG 100
#define PRICE_TAG 101
#define CERTIFICATION_TAG 102
#define DESCRIPTION_TAG 103

@interface ASZMenuDataController : NSObject <UITableViewDataSource>

@property(nonatomic,retain) ASBusiness* business;
@property(nonatomic,retain) ASZMenuList* menulist;

@end
