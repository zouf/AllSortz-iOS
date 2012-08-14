//
//  ASBusinessList.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/29/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASBusinessList.h"
#import "ASRateView.h"

#define NUM_STATIC_CELLS 1


@interface ASBusinessList ()


- (void)startIconDownload:(ASListing *)listing forIndexPath:(NSIndexPath *)indexPath;
@property (strong) NSArray *businesses;

@end


@implementation ASBusinessList

- (id)initWithJSONObject:(NSDictionary *)aJSONObject
{
    if (!(self = [super init]) || ![[aJSONObject objectForKey:@"success"] boolValue])
        return nil;
    _businesses = [aJSONObject objectForKey:@"result"];
    self.entries = [[NSMutableArray alloc]init];
    
    for(NSDictionary * dict in self.businesses)
    {
        //NSString *businessName = [dict objectForKey:@"businesName"];
        ASListing *listing = [[ASListing alloc]init];
        listing.businessName = [dict valueForKey:@"businessName"];
        listing.imageURLString = [dict valueForKey:@"photoURL"];
        listing.businessTypes = [dict valueForKey:@"types"];
        listing.businessDistance = [dict valueForKey:@"distanceFromCurrentUser"];
        listing.recommendation = [[dict valueForKey:@"ratingRecommendation"] floatValue];
        listing.userRating = [[dict valueForKey:@"ratingForCurrentUser"] floatValue];


        [self.entries addObject:listing];
    }
    
    return self;
}

#pragma mark - Key-value coding

- (NSUInteger)countOfBusinesses
{
    return [self.businesses count];
}

- (id)objectInBusinessesAtIndex:(NSUInteger)index
{
    return [self.businesses objectAtIndex:index];
}

- (NSArray *)businessesAtIndexes:(NSIndexSet *)indexes
{
    return [self.businesses objectsAtIndexes:indexes];
}

- (void)getBusinesses:(id __unsafe_unretained *)buffer range:(NSRange)inRange
{
    [self.businesses getObjects:buffer range:inRange];
}


#pragma mark - Table data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.entries count] + NUM_STATIC_CELLS;
}




@end
