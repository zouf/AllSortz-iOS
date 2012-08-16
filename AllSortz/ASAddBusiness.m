//
//  ASAddBusiness.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/14/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASAddBusiness.h"

// file "NSDictionary+UrlEncoding.m"


// helper function: get the string form of any object
static NSString *toString(id object) {
    return [NSString stringWithFormat: @"%@", object];
}

// helper function: get the url encoded string form of any object
static NSString *urlEncode(id object) {
    NSString *string = toString(object);
    return [string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}

@implementation NSDictionary (UrlEncoding)

-(NSString*) urlEncodedString {
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in self) {
        id value = [self objectForKey: key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", urlEncode(key), urlEncode(value)];
        [parts addObject: part];
    }
    return [parts componentsJoinedByString: @"&"];
}

@end

@implementation ASAddBusiness


- (id)initWithJSONObject:(NSDictionary *)aJSONObject
{
    if (!(self = [super init]) || ![[aJSONObject objectForKey:@"success"] boolValue])
        return nil;
    self.types = [[NSMutableArray alloc]init];
    NSDictionary * results = [aJSONObject objectForKey:@"result"];
    
    NSMutableArray *lTypes = [[NSMutableArray alloc] init];
    
    for (NSDictionary * dict in results)
    {
        NSString *name = [dict objectForKey:@"typeName"];
        [lTypes addObject:name];
        
    }
    self.types = lTypes;
    
    return self;
}
#warning - figure out a way to do this serialization better
- (NSDictionary *) serializeToDictionary
{
    NSDictionary * dict= [NSDictionary dictionaryWithObjectsAndKeys:
                          self.businessName, @"businessName",
                          self.businessPhone ,@"businessPhone",
                            self.businessAddress ,@"businessAddress",
                            self.businessURL ,@"businessURL",
                            self.businessCity, @"businessCity",
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
        return [self.types count];
        // select types...
    }
    
}

@end
