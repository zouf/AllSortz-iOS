//
//  ASUser.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/30/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASUser : NSObject

@property(atomic, retain) NSString *userName;
@property(nonatomic, retain) NSString *userEmail;
@property (nonatomic,retain) NSString *userPassword;


- (id)initWithJSONObject:(NSDictionary *)aJSONObject;


@end
