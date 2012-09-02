//
//  ASZBusinessDetailsViewController.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 8/9/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZBusinessDetailsViewController.h"

#import "ASZBusinessDetailsDataController.h"


@implementation ASZBusinessDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
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
       if ([self.dataController valueForKeyPath:@"business.image"] != nil)
        {
            UIImageView *imageView = (UIImageView*)[self.tableView viewWithTag:1000];
            imageView.image = [self.dataController valueForKeyPath:@"business.image"];
        }
        else
        {
       
            // Table view has to be refreshed on main thread
            [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                             withObject:nil
                                          waitUntilDone:NO];
        }
    }
}


#pragma mark - Table view delegate

- (void)singleTap:(UITapGestureRecognizer *)tap
{
    CGPoint currentTouchPosition = [tap locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    NSLog(@"Section is %d\n", indexPath.section );
    if (indexPath.section == 2)
    {
        NSLog(@"%d\n",indexPath.row);
        [self performSegueWithIdentifier:@"SegueTopicDetails" sender:self];
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
            return 132;
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
