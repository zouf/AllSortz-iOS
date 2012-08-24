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
    return 3;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
    {
        return 1;
    }
    else if (section == 1)
    {
        int ct = [self.allTypes count];
        return ct;
    }
    else
    {
        int ct = [self.allSorts count];
        return ct;
        
    }
    return 0;
}

- (NSDictionary *) serializeToDictionary
{
    NSError * error;
    NSData *typeData =  [NSJSONSerialization dataWithJSONObject:self.selectedTypes options:NSJSONWritingPrettyPrinted error:&error];
    NSString *typeString = [[NSString alloc] initWithData:typeData encoding:NSUTF8StringEncoding];
    
    NSData *sortData =  [NSJSONSerialization dataWithJSONObject:self.selectedSorts options:NSJSONWritingPrettyPrinted error:&error];
    NSString *sortString = [[NSString alloc] initWithData:sortData encoding:NSUTF8StringEncoding];
    
    NSDictionary * dict= [NSDictionary dictionaryWithObjectsAndKeys:
                         // self.distance, @"dw",
                          typeString, @"selectedTypes",
                          sortString, @"selectedSorts",
                          self.searchText ,@"searchText",
                          self.searchLocation ,@"location",nil];
    
    return dict;
}

@end
