//
//  ASQueryController.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/20/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASQueryController.h"

@interface ASQueryController () {
    NSArray *results;
}
@end

@implementation ASQueryController

// ========== UITableViewDataSource ==========

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSURL *url = [NSURL URLWithString:@"http://allsortz.com/ios/get_businesses/?uname=zouf"];

    // ==========
    // Not sure how to handle UI for asynchronous loading, so will do it
    // synchronously for now. In the main run loop, no less.
    //
    // REPLACE THIS ASAP, FFFFFFFUUUUUUUUUUU

    NSData *jsonData = [NSData dataWithContentsOfURL:url];
    NSDictionary *listings = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL];
    results = [listings objectForKey:@"result"];
    return [results count];

    // ==========
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
