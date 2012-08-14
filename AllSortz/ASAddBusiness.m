//
//  ASAddBusiness.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/14/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASAddBusiness.h"

@implementation ASAddBusiness


- (id)initWithJSONObject:(NSDictionary *)aJSONObject
{
    if (!(self = [super init]) || ![[aJSONObject objectForKey:@"success"] boolValue])
        return nil;
    self.types = [[NSMutableArray alloc]init];
    //NSLog(@"%@\n",self.sorts);
    NSDictionary * results = [aJSONObject objectForKey:@"result"];
    
    NSMutableArray *lTypes = [[NSMutableArray alloc] init];
    
    for (NSDictionary * dict in results)
    {
        NSString *name = [dict objectForKey:@"typeName"];
        [lTypes addObject:name];
        
    }
    self.types = lTypes;
    NSLog(@"%@\n", self.types);
    
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
    {
        return 1;   // one box to do it all..
        
    }
    if (section == 1)
    {
        return [self.types count];
        // select types...
    }
    
}

@end
