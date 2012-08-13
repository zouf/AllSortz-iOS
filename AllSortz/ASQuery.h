//
//  ASQuery.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/13/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASQuery : NSObject
{
    NSString *searchText;
    NSArray *categories;
    NSArray *sorts;
    float distance;
    float value;
    float price;
    float score;
}

@property(nonatomic, retain) NSString *searchText;
@property(nonatomic, retain) NSArray *types;
@property(nonatomic, retain) NSArray *sorts;
@property(assign) float distance;
@property(assign) float value;
@property(assign) float price;
@property(assign) float score;


- (id)initWithJSONObject:(NSDictionary *)aJSONObject;




@end
