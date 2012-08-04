//
//  ASListingsViewController.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/19/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASListingsViewController.h"
#import "ASBusinessListDataController.h"


@interface ASListingsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *listingsTable;
@property (strong, nonatomic) IBOutlet ASBusinessListDataController *listingsTableDataController;

@end


@implementation ASListingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
        return nil;
    return self;
}

#pragma mark - View controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.listingsTableDataController addObserver:self
                                       forKeyPath:@"businessList"
                                          options:NSKeyValueObservingOptionNew
                                          context:NULL];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self.listingsTableDataController removeObserver:self forKeyPath:@"businessList"];
    self.listingsTable = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Imitate default behavior of UITableViewController
    // deselectRowAtIndexPath:animated: should be fine taking a possible nil
    [self.listingsTable deselectRowAtIndexPath:[self.listingsTable indexPathForSelectedRow] animated:NO];

    // Download data automatically if there's no data source
    if (!self.listingsTableDataController.businessList)
        [self.listingsTableDataController updateData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Imitate default behavior of UITableViewController
    [self.listingsTable flashScrollIndicators];
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    // If the business list changes, reassign
    if ([keyPath isEqualToString:@"businessList"]) {
        id newDataSource = [change objectForKey:NSKeyValueChangeNewKey];
        self.listingsTable.dataSource = (newDataSource == [NSNull null] ? nil : newDataSource);
        [self.listingsTable reloadData];
    }
}

@end
