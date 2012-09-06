//
//  ASQuery.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/13/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASQuery.h"



@implementation ASQuery

- (id)initWithJSONObject:(NSDictionary *)aJSONObject
{
    if (!(self = [super init]) || ![[aJSONObject objectForKey:@"success"] boolValue])
        return nil;
    NSDictionary * results = [aJSONObject objectForKey:@"result"];
    _allSorts = [results objectForKey:@"topics"];
    _allTypes = [results objectForKey:@"types"];
    return self;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{    // Return the number of sections.
    
    // Use a third section for the 'topics' if you want to filter by topics that have given ratings
    return 2;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
    {
        return 1;
    }
    else 
    {
        int ct = [self.allTypes count];
        return ct;
    }
    // to include topics
   /* else
    {
        int ct = [self.allSorts count];
        return ct;
        
    }*/
    return 0;
}

- (NSDictionary *) serializeToDictionary
{
    NSError * error;
    NSString *typeString = @"";
    if (self.selectedTypes.count > 0)
    {
        NSData *typeData =  [NSJSONSerialization dataWithJSONObject:self.selectedTypes options:NSJSONWritingPrettyPrinted error:&error];
        typeString = [[NSString alloc] initWithData:typeData encoding:NSUTF8StringEncoding];
    }
    
    NSString *sortString = @"";
    if (self.selectedSorts.count > 0)
    {
        NSData *sortData =  [NSJSONSerialization dataWithJSONObject:self.selectedSorts options:NSJSONWritingPrettyPrinted error:&error];
        sortString = [[NSString alloc] initWithData:sortData encoding:NSUTF8StringEncoding];

    }
    

    NSDictionary * dict= [NSDictionary dictionaryWithObjectsAndKeys:
                          self.distanceWeight, @"dw",
                          typeString, @"selectedTypes",
                          sortString, @"selectedSorts",
                          self.searchText ,@"searchText",
                          self.searchLocation ,@"searchLocation",nil];
    
    return dict;
}

@end
