//
//  ASBusinessList.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/29/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASBusinessList.h"


@interface ASBusinessList ()

@property (strong) NSArray *businesses;

@end


@implementation ASBusinessList

- (id)initWithJSONObject:(NSDictionary *)aJSONObject
{
    if (!(self = [super init]) || ![[aJSONObject objectForKey:@"success"] boolValue])
        return nil;
    _businesses = [aJSONObject objectForKey:@"result"];
    return self;
}

/*
    ========== Key-value coding methods ==========
*/

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


/*
    ========== UITableViewDataSource methods ==========
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self valueForKeyPath:@"businesses.@count"] integerValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ListingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        // Create table cell if there isn't one to reuse
        // TODO: Change cell style when we implement our custom style
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    id business = [self objectInBusinessesAtIndex:indexPath.row];
    cell.textLabel.text = [business valueForKey:@"name"];
    cell.detailTextLabel.text = [business valueForKey:@"city"];
    return cell;
}

@end
