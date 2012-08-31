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

    [self.dataController addObserver:self
                          forKeyPath:@"business"
                             options:NSKeyValueObservingOptionNew
                             context:NULL];
//    [self.dataController addObserver:self
//                          forKeyPath:@"business.image"
//                             options:NSKeyValueObservingOptionNew
//                             context:NULL];

    [self.dataController refreshBusinessAsynchronouslyWithID:self.businessID];
}

- (void)viewDidUnload {
    [self.dataController removeObserver:self forKeyPath:@"business"];
//    [self.dataController removeObserver:self forKeyPath:@"business.image"];
    self.dataController = nil;

    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.dataController removeObserver:self forKeyPath:@"business"];
//    [self.dataController removeObserver:self forKeyPath:@"business.image"];
    [super viewDidDisappear:animated];
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
//    if ([keyPath isEqual:@"business"] || [keyPath isEqual:@"business.image"]) {
    if ([keyPath isEqual:@"business"]) {
//        // Table view has to be refreshed on main thread
        [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                         withObject:nil
                                      waitUntilDone:NO];
    }
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case ASZBusinessDetailsHeaderSection:
            return 132;
            break;
        case ASZBusinessDetailsInfoSection:
            return 22;
        case ASZBusinessDetailsTopicSection:
            return 88;
        default:
            return tableView.rowHeight;
            break;
    }
}

@end
