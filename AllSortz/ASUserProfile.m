//
//  ASUserProfile.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/23/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASUserProfile.h"

@implementation ASUserProfile

- (id)initWithJSONObject:(NSDictionary *)aJSONObject
{
    if (!(self = [super init]) || ![[aJSONObject objectForKey:@"success"] boolValue])
        return nil;
    self.sorts = [aJSONObject objectForKey:@"result"];
    for (int i = 0; i < [self.sorts count]; i++)
    {
        [self.importance addObject:[NSNumber numberWithFloat:0] ];
    }
    return self;
}

- (NSDictionary *) serializeToDictionary
{
    //NSError * error;
    //NSData *jsonData =  [NSJSONSerialization dataWithJSONObject:self.selectedTypes options:NSJSONWritingPrettyPrinted error:&error];
    //NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
   /* NSDictionary * dict= [NSDictionary dictionaryWithObjectsAndKeys:
                          self.businessName, @"businessName",
                          self.businessPhone ,@"businessPhone",
                          self.businessAddress ,@"businessAddress",
                          self.businessURL ,@"businessURL",
                          self.businessCity, @"businessCity",
                          self.businessPhotoURL, @"photoURL",
                          
                          jsonString, @"selectedTypes",
                          self.businessState ,@"businessState",nil];
    
    return dict;*/
    return nil;
}


#pragma mark - Table data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sorts count] ;
}

@end
