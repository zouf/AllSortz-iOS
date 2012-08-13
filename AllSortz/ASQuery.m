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
    self.sorts = [[NSMutableArray alloc]init];
    //NSLog(@"%@\n",self.sorts);
    NSDictionary * results = [aJSONObject objectForKey:@"result"];
    
    NSMutableArray *lSorts = [[NSMutableArray alloc] init];
    for (NSDictionary * dict in [results objectForKey:@"tags"])
    {
        NSString *name = [dict objectForKey:@"tagName"];
        [lSorts addObject:name];
    }
    NSMutableArray *lTypes = [[NSMutableArray alloc] init];

    for (NSDictionary * dict in [results objectForKey:@"types"])
    {
        NSString *name = [dict objectForKey:@"typeName"];
        [lTypes addObject:name];

    }
    self.sorts = lSorts;
    self.types = lTypes;
    NSLog(@"%@\n", self.types);
    NSLog(@"%@\n", self.sorts);

    return self;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    NSLog(@"NUmber of rows!\n");
    if (section == 0)
    {
        return 0;
    }
    else if (section == 1)
    {
        NSLog(@"Returning %d\n",[self.sorts count]);
        return [self.types count];
    }
    else
    {
        return [self.sorts count];
        
    }
    return 0;
}

@end
