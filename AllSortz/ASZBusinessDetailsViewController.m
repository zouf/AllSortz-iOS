//
//  ASZBusinessDetailsViewController.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 8/9/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZBusinessDetailsViewController.h"

#import "ASZBusinessDetailsDataController.h"

#import "ASZTopicDetailViewController.h"

@implementation ASZBusinessDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    singleTap.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:singleTap];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.dataController addObserver:self
                          forKeyPath:@"business"
                             options:NSKeyValueObservingOptionNew
                             context:NULL];
    [self.dataController addObserver:self
                          forKeyPath:@"business.image"
                             options:NSKeyValueObservingOptionNew
                             context:NULL];
    
    [self.dataController refreshBusinessAsynchronouslyWithID:self.businessID];
}

- (void)viewDidUnload {
    [self.dataController removeObserver:self forKeyPath:@"business"];
    [self.dataController removeObserver:self forKeyPath:@"business.image"];
    self.dataController = nil;

    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.dataController removeObserver:self forKeyPath:@"business"];
    [self.dataController removeObserver:self forKeyPath:@"business.image"];
    [super viewDidDisappear:animated];
}


#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"business"] || [keyPath isEqual:@"business.image"]) {
        if ([self.dataController valueForKeyPath:@"business.image"] != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *imageView = (UIImageView*)[self.tableView viewWithTag:1000];
                imageView.image = [self.dataController valueForKeyPath:@"business.image"];
            });
        } else {
            // Table view has to be refreshed on main thread
            [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                             withObject:nil
                                        waitUntilDone:NO];
        }
        
    }
}

- (IBAction)dialBusinessPhone {
    // TODO: Implement once taps are passed through
    return;
}

#pragma mark - Table view delegate

- (void)singleTap:(UITapGestureRecognizer *)tap
{
    CGPoint currentTouchPosition = [tap locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath.section == 2)
    {
        id bus  = self.dataController.business;
        id topics = [bus valueForKey:@"topics"];
                
        NSArray *topicsArray = (NSArray*)topics;
        id topic = topicsArray[indexPath.row];
        NSInteger topicID = [[topic valueForKey:@"ID"] integerValue];

        
        NSString *targetViewControllerIdentifier = nil;
        targetViewControllerIdentifier = @"TopicDetailViewControllerID";
        ASZTopicDetailViewController *vc = (ASZTopicDetailViewController*)[self.storyboard instantiateViewControllerWithIdentifier:targetViewControllerIdentifier];
        
        
        
        ASZTopicDetailDataController *topicDetailsController = vc.dataController;
        ASZBusinessDetailsDataController *businessDetailsController = self.dataController;
        topicDetailsController.username = businessDetailsController.username;
        topicDetailsController.password = businessDetailsController.password;
        topicDetailsController.UUID = businessDetailsController.UUID;
        topicDetailsController.currentLatitude = businessDetailsController.currentLatitude;
        topicDetailsController.currentLongitude = businessDetailsController.currentLongitude;
        
        topicDetailsController.topic = [[ASZTopic alloc] initWithID:topicID];
        topicDetailsController.topic.name = [topic valueForKey:@"name"];
        topicDetailsController.topic.summary = [topic valueForKey:@"summary"];
        topicDetailsController.topic.rating = [[topic valueForKey:@"rating"] floatValue];


        [self.navigationController  pushViewController:vc animated:YES];
        
    }
}



- (void)tableView:(UITableView *)tableViewdidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case ASZBusinessDetailsHeaderSection:
            return 230;
            break;
        case ASZBusinessDetailsInfoSection:
            return 22;
        case ASZBusinessDetailsTopicSection:
            return 100;
        default:
            return tableView.rowHeight;
            break;
    }
}

@end
