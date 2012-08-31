//
//  ASBusinessList.h
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/29/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASIconDownloader.h"

#define IMAGE_VIEW 102
#define RATING_VIEW 100
#define DISTANCE_VIEW 105
#define TYPE_LABEL 104
#define PRICE_VIEW 107
#define RATE_VIEW 106

@interface ASBusinessList : NSObject <UITableViewDataSource>
{
    NSMutableDictionary *imageDownloadsInProgress;  // the set of IconDownloader objects for each app
}

- (id)initWithJSONObject:(NSDictionary *)aJSONObject;

// Key-value coding
- (NSUInteger)countOfBusinesses;
- (id)objectInBusinessesAtIndex:(NSUInteger)index;
- (NSArray *)businessesAtIndexes:(NSIndexSet *)indexes;
- (void)getBusinesses:(id __unsafe_unretained *)buffer range:(NSRange)inRange;

// the main data model for our UITableView
@property (nonatomic, retain) NSMutableArray *entries;





@end
