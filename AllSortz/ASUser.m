//
//  ASUser.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/30/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASUser.h"
@interface ASUser ()

@property NSOperationQueue *queue;  // Assume we only need one for now

@end
@implementation ASUser


- (id)initWithJSONObject:(NSDictionary *)aJSONObject
{
    if (!(self = [super init]) )//|| ![[aJSONObject objectForKey:@"success"] boolValue])
        return nil;
   // NSMutableDictionary *results = [aJSONObject objectForKey:@"result"];
    // [self.treePath addObject:[allTopics valueForKey:@"topicName"]];
    
    
    
    self.userName = [aJSONObject objectForKey:@"userName"];
    self.userEmail = [aJSONObject objectForKey:@"userEmail"] ;
    
    
    NSDictionary * profile = [aJSONObject objectForKey:@"profile"];
    if ([profile objectForKey:@"profilePic"])
    {
        NSURL *url = [NSURL URLWithString:[profile valueForKey:@"profilePic"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        void (^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.profilePicture = [UIImage imageWithData: data];
                [self.delegate imageDidLoad:self];


            });

        };
        
        if (!self.queue)
            self.queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:handler];

        

    }
    
    NSString *reg = [aJSONObject objectForKey:@"registered"];
    if (reg)
    {
        if ([reg isEqualToString:@"false"])
        {
            self.registered = NO;
        }
        else
        {
            self.registered = YES;
        }
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
