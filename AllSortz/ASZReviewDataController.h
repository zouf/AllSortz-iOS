//
//  ASZReviewDataController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/15/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASZReview.h"

@interface ASZReviewDataController : NSObject <UITableViewDataSource>
@property ASZReview *review;

@property NSString *username;
@property NSString *password;
@property CGFloat currentLatitude;
@property CGFloat currentLongitude;
@property NSString *UUID;

- (void)getReviewInfo:(NSUInteger)ID;
- (void)submitReviewWithTopics:(NSArray*)topics;
- (void)submitComment;

@end
