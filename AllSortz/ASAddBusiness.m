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
    self.allTypes = [aJSONObject objectForKey:@"result"];
    
    return self;
}
#warning - figure out a way to do this serialization better
- (NSDictionary *) serializeToDictionary
{
    NSError * error;
    NSData *jsonData =  [NSJSONSerialization dataWithJSONObject:self.selectedTypes options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary * dict= [NSDictionary dictionaryWithObjectsAndKeys:
                          self.businessName, @"businessName",
                          self.businessPhone ,@"businessPhone",
                            self.businessAddress ,@"businessAddress",
                            self.businessURL ,@"businessURL",
                            self.businessCity, @"businessCity",
                         jsonString, @"selectedTypes",
                            self.businessState ,@"businessState",nil];
    
    return dict;
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
        return [self.allTypes count];
    }
    assert(NO);
}

@end
