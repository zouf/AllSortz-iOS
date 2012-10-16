//
//  ASZReviewViewController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/15/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZReviewViewController.h"

@interface ASZReviewViewController ()

@end

@implementation ASZReviewViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self.dataController addObserver:self
                          forKeyPath:@"review"
                             options:NSKeyValueObservingOptionNew
                             context:NULL];

    
    //review from the main page
    if (self.businessID) //REVIEW
    {
        [self.dataController getReviewInfo:self.businessID];
    }
    else if (self.bustopicID) //COMMENT
    {
        self.dataController.review = [[ASZReview alloc]initWithID:self.bustopicID :self.replyToID];
    }



    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.dataController removeObserver:self forKeyPath:@"review"];

}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    [self.dataController removeObserver:self forKeyPath:@"review"];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (IBAction)submitTapped:(id)sender {
    UITextView *tv = (UITextView*)[self.tableView viewWithTag:201];
    [self.dataController.review setReviewText:tv.text];
    if (self.businessID)
    {
        NSMutableArray *topicIDs = [[NSMutableArray alloc]init];
        for (NSMutableDictionary*d in self.dataController.review.allTopics)
        {
            NSString * selected = [d valueForKey:@"selected"];
            if ([selected isEqualToString:@"true"])
            {
                [topicIDs addObject:[d valueForKey:@"ID"]];
            }
        }

        [self.dataController submitReviewWithTopics:topicIDs];
    }
    else if (self.bustopicID)
    {
       [self.dataController submitComment];
    }

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Remove the view


- (IBAction)cancelTapped:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"review"]) {
        /*if ([self.dataController valueForKeyPath:@"review"] != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *imageView = (UIImageView*)[self.tableView viewWithTag:1000];
                imageView.image = [self.dataController valueForKeyPath:@"business.image"];
            });
        } else {*/
            // Table view has to be refreshed on main thread
            [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                             withObject:nil
                                          waitUntilDone:NO];
        //}
        
    }
}


#pragma mark - Table view delegate


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1)
    {
        id topic = self.dataController.review.allTopics[indexPath.row];
                    [topic setValue:@"false" forKey:@"selected"];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1)
    {
        id topic = self.dataController.review.allTopics[indexPath.row];
        [topic setValue:@"true" forKey:@"selected"];
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 150;
            break;
        case 1:
            return 45;
            break;
        default:
            return tableView.rowHeight;
            break;
    }
}


@end
