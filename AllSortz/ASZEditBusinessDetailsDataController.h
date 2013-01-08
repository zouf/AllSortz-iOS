//
//  ASZEditBusinessDetailsDataController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/5/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASBusiness;


@interface ASZEditBusinessDetailsDataController : NSObject <UITableViewDataSource>

@property ASBusiness *business;

@property NSMutableArray *allTypes;


@property NSString *username;
@property NSString *password;
@property CGFloat currentLatitude;
@property CGFloat currentLongitude;
@property NSString *UUID;

- (void)refreshBusinessAsynchronouslyWithID:(id)ID;
- (void)editBusinessAsynchronouslyWithID:(id)ID;

@end
