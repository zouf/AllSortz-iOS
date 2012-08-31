//
//  ASUser.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/30/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASUser.h"

@implementation ASUser


- (id)initWithJSONObject:(NSDictionary *)aJSONObject
{
    if (!(self = [super init]) || ![[aJSONObject objectForKey:@"success"] boolValue])
        return nil;
    NSMutableDictionary *results = [aJSONObject objectForKey:@"result"];
    // [self.treePath addObject:[allTopics valueForKey:@"topicName"]];
    self.userName = [results valueForKey:@"userName"];
    self.userEmail = [results valueForKey:@"userEmail"] ;
  //  self.userPassword = [results valueForKey:@"userPassword"];

    return self;
}




@end
