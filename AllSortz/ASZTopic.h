//
//  ASZTopic.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/2/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface ASZTopic : NSObject


@property (readonly) NSUInteger ID;

// TODO: Use more structured repr for location, hours, and phone

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *summary;
@property (nonatomic) float rating;



- (id)initWithID:(NSUInteger)anID;



@end
