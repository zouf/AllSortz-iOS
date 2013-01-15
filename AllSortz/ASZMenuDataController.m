//
//  ASZMenuDataController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 1/8/13.
//  Copyright (c) 2013 AllSortz, Inc. All rights reserved.
//

#import "ASZMenuDataController.h"
@implementation ASZMenuDataController
@synthesize business;
@synthesize  menulist;

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.menulist numberOfMeals];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.menulist numberOfMenuItemsFor:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ASZMenuItem * mi = [self.menulist menuItemsForIndex:indexPath];
    static NSString *CellIdentifier = @"MenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UITextView *description = (UITextView*)[cell viewWithTag:DESCRIPTION_TAG];
    description.text = mi.description;
    
    UILabel *name = (UILabel*)[cell viewWithTag:NAME_TAG];
    name.text = mi.name;
    
    UILabel *price = (UILabel *)[cell viewWithTag:PRICE_TAG];
    price.text = [mi.price stringValue];
    
    //need to do this programatically. I reset the image just to show where this needs to be done and to debug
    UIImageView * certificationImage = (UIImageView *)[cell viewWithTag:CERTIFICATION_TAG];
    certificationImage.image = mi.certImage;
    return cell;
}


@end
