//
//  ASZTopicDetailViewController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/2/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZTopicDetailViewController.h"



#define CELL_WIDTH 300
#define CELL_MARGIN 10
#define BUTTON_SPACE 150
@interface ASZTopicDetailViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ASZTopicDetailViewController
@synthesize tableView;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return 110;
            break;
        case 1:
        {
            
            NSString * text =   self.dataController.topic.summary;
            
            CGSize constraint = CGSizeMake(CELL_WIDTH - (CELL_MARGIN * 2), 20000.0f);
            
            CGSize size = [text sizeWithFont:[UIFont fontWithName:@"Gill Sans Light" size:14.0] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            
            CGFloat height = MAX(size.height, 44.0f);
            
            return height + (CELL_MARGIN * 2) + BUTTON_SPACE 	;
            break;
        }
        default:
            return self.tableView.rowHeight;
            break;
    }
}


@end
