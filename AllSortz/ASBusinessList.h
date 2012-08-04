//
//  ASBusinessList.h
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/29/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

@interface ASBusinessList : NSObject <UITableViewDataSource>

- (id)initWithJSONObject:(NSDictionary *)aJSONObject;

// Key-value coding
- (NSUInteger)countOfBusinesses;
- (id)objectInBusinessesAtIndex:(NSUInteger)index;
- (NSArray *)businessesAtIndexes:(NSIndexSet *)indexes;
- (void)getBusinesses:(id __unsafe_unretained *)buffer range:(NSRange)inRange;

@end
