//
//  ASZTopicDetailDataController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/2/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZTopicDetailDataController.h"

#define TOPICSUMMARY_TAG 1020
#define TOPICNAME_TAG 1021
#define TOPICRATING_TAG 1022
#define TOPICEDITBUTTON_TAG 1023

@implementation ASZTopicDetailDataController
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}


- (IBAction)editDonePressed:(id)sender {
//    UITableViewCell *cell = (UITableViewCell*)sender;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = nil;
    UITableViewCell *cell= nil;
    
    NSLog(@"%d\n",indexPath.row);
    // top row for label and rating
    if (indexPath.row == 0)
    {
        CellIdentifier = @"TopicTitleCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        UILabel * title = (UILabel *)[cell viewWithTag:TOPICNAME_TAG];
        title.text = self.topic.name;
        
        UISlider *slider = (UISlider *)[cell viewWithTag:TOPICRATING_TAG];
        slider.value = self.topic.rating;
        
        
    }
    else if (indexPath.row==1)  // for the text summary
    {
        CellIdentifier = @"TopicSummaryCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UITextView *summaryText = (UITextView*)[cell viewWithTag:TOPICSUMMARY_TAG];
        summaryText.text = self.topic.summary;
        [summaryText setEditable:NO];
        
        UIButton *button = (UIButton*)[cell viewWithTag:TOPICEDITBUTTON_TAG];
        button.titleLabel.text = @"Edit Summary";
        [button addTarget:self action:@selector(editDonePressed:) forControlEvents:UIControlEventTouchDown];
        return cell;
    }
    else
    {
        return cell;
    }
    
    // Configure the cell...
    
    return cell;
}



 

@end
