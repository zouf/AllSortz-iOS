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
    NSString *reg = [results valueForKey:@"registered"];

    if ([reg isEqualToString:@"false"])
    {
        self.registered = NO;
    }
    else
    {
        self.registered = YES;
    }
    return self;
}

- (NSDictionary *) serializeToDictionary
{
    //NSError * error;
    //NSData *jsonData =  [NSJSONSerialization dataWithJSONObject:self.selectedTypes options:NSJSONWritingPrettyPrinted error:&error];
    //NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
     NSDictionary * dict= [NSDictionary dictionaryWithObjectsAndKeys:
     self.userName, @"userName",
     self.userEmail ,@"userEmail",
     self.userPassword ,@"userPassword",nil];
     
    return dict;
}



@end
