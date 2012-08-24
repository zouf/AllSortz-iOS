//
//  ASUserProfile.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/23/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASUserProfile : NSObject <UITableViewDataSource>

@property(nonatomic, retain) NSMutableArray *topics;
@property(nonatomic, retain) NSMutableDictionary *tree;
@property (nonatomic,retain) NSMutableArray *treePath;


@property(nonatomic, retain) NSMutableArray *importance;

//@property(nonatomic, retain) NSArray *allTypes;

- (id)initWithJSONObject:(NSDictionary *)aJSONObject;
- (NSDictionary *)serializeToDictionary;



@end
