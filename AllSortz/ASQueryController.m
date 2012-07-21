//
//  ASQueryController.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/20/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASQueryController.h"

@implementation ASQueryController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (!(cell = [tableView dequeueReusableCellWithIdentifier:@"ListingCell"])) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ListingCell"];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    return cell;
}

@end
