//
//  ASBusinessList.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/29/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASBusinessList.h"
#import "ASRateView.h"

#define NUM_STATIC_CELLS 2


@interface ASBusinessList ()


@property (strong) NSArray *businesses;

@end


@implementation ASBusinessList

- (id)initWithJSONObject:(NSDictionary *)aJSONObject
{
    if (!(self = [super init]) || ![[aJSONObject objectForKey:@"success"] boolValue])
        return nil;
    _businesses = [aJSONObject objectForKey:@"result"];
    _entries = [[NSMutableArray alloc]init];
    
    for(NSDictionary * dict in _businesses)
    {
        //NSString *businessName = [dict objectForKey:@"businesName"];  
        NSUInteger listingID = [[dict valueForKey:@"businessID"] unsignedIntegerValue];
        ASListing *listing = [[ASListing alloc] initWithID:listingID];

        
        listing.businessName = [dict valueForKey:@"businessName"];
        listing.averagePrice = [dict valueForKey:@"averagePrice"];
        listing.imageURLString = [dict valueForKey:@"photoMedURL"];
        listing.businessTypes = [dict valueForKey:@"types"];
        listing.businessDistance = [dict valueForKey:@"distanceFromCurrentUser"];
        listing.recommendation = [[dict valueForKey:@"ratingRecommendation"] floatValue];
        listing.userRating = [[dict valueForKey:@"ratingForCurrentUser"] floatValue];
        listing.latitude =  [[dict valueForKey:@"latitude"] floatValue];
        listing.longitude =  [[dict valueForKey:@"longitude"] floatValue];

        [_entries addObject:listing];
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
