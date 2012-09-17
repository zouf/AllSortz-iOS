//
//  ASZBusinessTopicDataController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/16/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASZCommentList.h"

@interface ASZBusinessTopicDataController : NSObject <UITableViewDataSource>
@property ASZCommentList *commentList;

@property NSString *username;
@property NSString *password;
@property CGFloat currentLatitude;
@property CGFloat currentLongitude;
@property NSString *UUID;

- (void)getCommentList:(NSUInteger)btID;
- (void)submitModifiedBusTopicContent:(NSUInteger)btID;
@end
