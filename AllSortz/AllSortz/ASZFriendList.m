//
//  ASZFriendList.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 10/22/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZFriendList.h"

@implementation ASZFriendList
-(ASZFriendList*)initWithJSON:(NSDictionary*)result delegateForUserProfilePic:(id)delegate
{
    
    self.users = [[NSMutableArray alloc]init];
    self.selectedUsers = [[NSMutableDictionary alloc]init];
    for(NSDictionary *d in [result valueForKey:@"users"])
    {
        ASUser * u = [[ASUser alloc]initWithJSONObject:d];
        u.delegate = delegate;
        [self.users addObject:u];
        [self.selectedUsers setValue:NO forKey:u.userName];
        NSLog(@"%@\n",[u description]);
    }
    
    return self;
}
@end
