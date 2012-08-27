//
//  ASQuery.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/13/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

@interface ASQuery : NSObject

@property(nonatomic, retain) NSString *searchText;
@property(nonatomic, retain) NSString *searchLocation;

@property(nonatomic, retain) NSArray *allTypes;
@property(nonatomic, retain) NSArray *allSorts;
@property(nonatomic, retain) NSArray *selectedTypes;
@property(nonatomic, retain) NSArray *selectedSorts;
@property(nonatomic, retain) NSArray *distanceWeight;

/*@property(nonatomic,retain) NSNumber * distance;
@property(nonatomic,retain) NSNumber * value;

@property(nonatomic,retain) NSNumber * price;

@property(nonatomic,retain) NSNumber * score;*/



- (id)initWithJSONObject:(NSDictionary *)aJSONObject;
- (NSDictionary *)serializeToDictionary;



@end
