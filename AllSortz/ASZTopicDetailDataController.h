//
//  ASZTopicDetailDataController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/2/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASZTopic.h"


@interface ASZTopicDetailDataController : NSObject <UITableViewDataSource>

@property ASZTopic *topic;

@property NSString *username;
@property NSString *password;
@property CGFloat currentLatitude;
@property CGFloat currentLongitude;
@property NSString *UUID;

- (void)refreshBusinessAsynchronouslyWithID:(NSUInteger)ID;

@end
