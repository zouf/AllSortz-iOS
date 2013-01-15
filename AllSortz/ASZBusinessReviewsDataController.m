//
//  ASZBusinessReviewsDataController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 1/9/13.
//  Copyright (c) 2013 AllSortz, Inc. All rights reserved.
//

#import "ASZBusinessReviewsDataController.h"

@implementation ASZBusinessReviewsDataController
@synthesize business;

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.business.reviews.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BasicReviewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITextView *tv = (UITextView*)[cell viewWithTag:102];
    UILabel *name  = (UILabel*)[cell viewWithTag:100];
    UILabel * date = (UILabel*)[cell viewWithTag:101];
    UIImageView * reviewRating = (UIImageView*)[cell viewWithTag:104];

    id review = [self.business.reviews objectAtIndex:indexPath.row];
    
    tv.text = [review objectForKey:@"excerpt"];
    name.text = [[review objectForKey:@"user"] objectForKey:@"name"];
    
    //TODO convert to date
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:
     (NSTimeInterval)[[review objectForKey:@"time_created"] doubleValue]];
    [df setDateFormat:@"dd MM yyyy"];
    
    NSString *dateString =[df stringFromDate:d]; //give date here

    date.text = dateString;
    //TODO make asynchronous
    NSLog(@"%@\n",review);
    NSURL *url = [NSURL URLWithString:[review objectForKey:@"rating_image_large_url"]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData:data];
    reviewRating.image = img;
    return cell;
}

@end
