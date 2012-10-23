//
//  ASZFriendList.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 10/22/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASUser.h"

@interface ASZFriendList : NSObject

//the delegate is the object that is used as the delegate for downloading the user profile pictures.
// We shouldn't list users without their pictures, and this needs to be done asynchronously
-(ASZFriendList*)initWithJSON:(NSDictionary*)result delegateForUserProfilePic:(id)delegate;
@property(nonatomic,strong) NSMutableArray *users;
@property(nonatomic,strong) NSMutableDictionary *selectedUsers;


@end

