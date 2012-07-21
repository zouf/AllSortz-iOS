//
//  ASListingsViewController.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/19/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASListingsViewController.h"


@class ASQueryController;


@interface ASListingsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *listingsTable;
@property (strong, nonatomic) IBOutlet ASQueryController *queryController;

@end


@implementation ASListingsViewController

@synthesize listingsTable = _listingsTable;
@synthesize queryController = _queryController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
        return nil;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setListingsTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Imitate default behavior of UITableViewController
    // deselectRowAtIndexPath:animated: should be fine taking a possible nil
    [self.listingsTable deselectRowAtIndexPath:[self.listingsTable indexPathForSelectedRow] animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Imitate default behavior of UITableViewController
    [self.listingsTable flashScrollIndicators];
}

@end
